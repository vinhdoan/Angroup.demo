<%@ Control Language="C#" ClassName="pagePanel" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Web" %>
<%@ Import Namespace="System.Web.UI" %>
<%@ Import Namespace="System.Web.UI.WebControls" %>
<%@ Import Namespace="System.ComponentModel" %>
<%@ Import Namespace="Anacle.DataFramework" %>

<script runat="server">
    [Localizable(true)]
    public string Caption
    {
        get
        {
            return labelCaption.Text;
        }
        set
        {
            labelCaption.Text = value;
        }
    }

    [Localizable(true)]
    public string Message
    {
        get
        {
            return labelMessage.Text;
        }
        set
        {
            if (value.Trim() != "")
                panelMessage.Update();
            labelMessage.Text = value;
        }
    }


    protected override void OnInit(EventArgs e)
    {
        UIButton1.Click += new EventHandler(UIButton1_Click);
        UIButton2.Click += new EventHandler(UIButton2_Click);
        UIButton3.Click += new EventHandler(UIButton3_Click);
        UIButton4.Click += new EventHandler(UIButton4_Click);

        base.OnInit(e);
    }



    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);

        if (!IsPostBack)
        {
            linkClose.Attributes["onclick"] = "document.getElementById('" + tableMessage.ClientID + "').style.visibility = 'hidden'";
        }
    }

    //--------------------------------------------
    // button1
    //--------------------------------------------
    [Localizable(true)]
    public string Button1_Caption
    {
        get { return UIButton1.Text; }
        set { UIButton1.Text = value; }
    }

    public string Button1_ImageUrl
    {
        get { return UIButton1.ImageUrl; }
        set { UIButton1.ImageUrl = value; }
    }

    public string Button1_CommandName
    {
        get { return UIButton1.CommandName; }
        set { UIButton1.CommandName = value; }
    }

    public bool Button1_CausesValidation
    {
        get { return UIButton1.CausesValidation; }
        set { UIButton1.CausesValidation = value; }
    }

    [Localizable(true)]
    public string Button1_ConfirmText
    {
        get { return UIButton1.ConfirmText; }
        set { UIButton1.ConfirmText = value; }
    }
    

    //--------------------------------------------
    // button2
    //--------------------------------------------
    [Localizable(true)]
    public string Button2_Caption
    {
        get { return UIButton2.Text; }
        set { UIButton2.Text = value; }
    }

    public string Button2_ImageUrl
    {
        get { return UIButton2.ImageUrl; }
        set { UIButton2.ImageUrl = value; }
    }

    public string Button2_CommandName
    {
        get { return UIButton2.CommandName; }
        set { UIButton2.CommandName = value; }
    }

    public bool Button2_CausesValidation
    {
        get { return UIButton2.CausesValidation; }
        set { UIButton2.CausesValidation = value; }
    }

    [Localizable(true)]
    public string Button2_ConfirmText
    {
        get { return UIButton2.ConfirmText; }
        set { UIButton2.ConfirmText = value; }
    }
    

    //--------------------------------------------
    // button3
    //--------------------------------------------
    [Localizable(true)]
    public string Button3_Caption
    {
        get { return UIButton3.Text; }
        set { UIButton3.Text = value; }
    }

    public string Button3_ImageUrl
    {
        get { return UIButton3.ImageUrl; }
        set { UIButton3.ImageUrl = value; }
    }

    public string Button3_CommandName
    {
        get { return UIButton3.CommandName; }
        set { UIButton3.CommandName = value; }
    }

    public bool Button3_CausesValidation
    {
        get { return UIButton3.CausesValidation; }
        set { UIButton3.CausesValidation = value; }
    }

    [Localizable(true)]
    public string Button3_ConfirmText
    {
        get { return UIButton3.ConfirmText; }
        set { UIButton3.ConfirmText = value; }
    }
    
   

    //--------------------------------------------
    // button4
    //--------------------------------------------
    [Localizable(true)]
    public string Button4_Caption
    {
        get { return UIButton4.Text; }
        set { UIButton4.Text = value; }
    }

    public string Button4_ImageUrl
    {
        get { return UIButton4.ImageUrl; }
        set { UIButton4.ImageUrl = value; }
    }

    public string Button4_CommandName
    {
        get { return UIButton4.CommandName; }
        set { UIButton4.CommandName = value; }
    }

    public bool Button4_CausesValidation
    {
        get { return UIButton4.CausesValidation; }
        set { UIButton4.CausesValidation = value; }
    }

    [Localizable(true)]
    public string Button4_ConfirmText
    {
        get { return UIButton4.ConfirmText; }
        set { UIButton4.ConfirmText = value; }
    }
    
    
    
    void UIButton4_Click(object sender, EventArgs e)
    {
        if (Click != null)
            Click(this, this.Button4_CommandName);
    }

    void UIButton3_Click(object sender, EventArgs e)
    {
        if (Click != null)
            Click(this, this.Button3_CommandName);
    }

    void UIButton2_Click(object sender, EventArgs e)
    {
        if (Click != null)
            Click(this, this.Button2_CommandName);
    }

    void UIButton1_Click(object sender, EventArgs e)
    {
        if (Click != null)
            Click(this, this.Button1_CommandName);
    }



    protected override void OnPreRender(EventArgs e)
    {
        base.OnPreRender(e);
        tableMessage.Visible = this.Message.Trim() != "";

        UIButton1.Visible = Button1_CommandName.Trim() != "";
        UIButton2.Visible = Button2_CommandName.Trim() != "";
        UIButton3.Visible = Button3_CommandName.Trim() != "";
        UIButton4.Visible = Button4_CommandName.Trim() != "";
    }


    public delegate void PagePanelClickEventHandler(object sender, string commandName);


    [Browsable(true)]
    public event PagePanelClickEventHandler Click;
</script>

<ui:UIPanel runat="server" ID="panel">
    <div>
        <ui:UIPanel runat="server" ID="panelCaption" CssClass="search-name">
            <asp:Label ID="labelCaption" runat="server"></asp:Label>
        </ui:UIPanel>
        <ui:UIPanel runat="server" ID="panelButtons" CssClass="search-buttons">
            <ui:UIButton runat="server" ID="UIButton1" />
            <ui:UIButton runat="server" ID="UIButton2" />
            <ui:UIButton runat="server" ID="UIButton3" />
            <ui:UIButton runat="server" ID="UIButton4" />
        </ui:UIPanel>
    </div>
    <ui:UIPanel runat="server" ID="panelMessage" HorizontalAlign="Center">
        <div runat="server" id="tableMessage" class="object-message" style="top: -50px; width: 100%;
            position: absolute;">
            <table style="width: 100%" cellpadding="5">
                <tr>
                    <td>
                        <table border="0" cellspacing="0" cellpadding="0" width="100%">
                            <tr valign="top">
                                <td align="left">
                                    <asp:Label runat='server' ID='labelMessage' meta:resourcekey="labelMessageResource1">
                                    </asp:Label>
                                </td>
                                <td align="right">
                                    <asp:HyperLink runat="server" ID="linkClose" Text="Hide" NavigateUrl="javascript:void(0)"></asp:HyperLink>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
            </table>
        </div>
        <asp:AnimationExtender ID="AnimationExtender1" runat="server" TargetControlID="tableMessage">
            <Animations>
                <OnLoad>
                    <Parallel duration="0.3">
                        <FadeIn fps="10"></FadeIn>
                        <Move vertical="50" fps="10"></Move>
                    </Parallel>
                </OnLoad>
            </Animations>
        </asp:AnimationExtender>
        <asp:AlwaysVisibleControlExtender runat="server" ID="acv1" TargetControlID="tableMessage">
        </asp:AlwaysVisibleControlExtender>
    </ui:UIPanel>
</ui:UIPanel>
