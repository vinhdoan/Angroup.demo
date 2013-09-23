//========================================================================
// $Product: Anacle Enterprise Asset Management
// $Version: 5.0
//
// Copyright 2006 (c) Anacle Systems Pte. Ltd.
// All rights reserved.
//========================================================================
using System;
using System.IO;
using System.Collections;
using System.Collections.Generic;
using System.Data;
using System.Configuration;
using System.Globalization;
using System.Threading;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;

using Anacle.UIFramework;
using Anacle.DataFramework;
using LogicLayer;

/// <summary>
/// Summary description for PageBase
/// </summary>
public class PageBase : Anacle.UIFramework.UIPageBase
{

    protected TextBox ViewStateKey;

    public PageBase()
    {
        //
        // TODO: Add constructor logic here
        //
    }

    /// ------------------------------------------------------------------
    /// <summary>
    /// Initialize the page culture.
    /// </summary>
    /// ------------------------------------------------------------------
    protected override void InitializeCulture()
    {
        CultureInfo ci = null;

        // Creates the new culture info object based on the currently
        // logged on user's language.
        //
        if (AppSession.User!=null &&
            AppSession.User.LanguageName != null &&
            AppSession.User.LanguageName.Trim() != "")
            ci = new CultureInfo(AppSession.User.LanguageName);
        else
            ci = new CultureInfo("");

        // Initialize currency symbols
        //
        OCurrency currency = OApplicationSetting.Current.BaseCurrency;
        if (currency != null)
            ci.NumberFormat.CurrencySymbol = currency.CurrencySymbol;

        // Initialize the page culture.
        //
        this.Culture = ci.Name;
        this.UICulture = ci.Name;

        // Then sets the culture across all libraries.
        //
        Resources.Errors.Culture = ci;
        Resources.Objects.Culture = ci;
        Resources.Messages.Culture = ci;
        Resources.Roles.Culture = ci;
        Resources.Strings.Culture = ci;

        LogicLayer.Global.SetCulture(ci);
        Anacle.UIFramework.Global.SetCulture(ci);

        Thread.CurrentThread.CurrentCulture = ci;
        Thread.CurrentThread.CurrentUICulture = ci;

        base.InitializeCulture();
    }


    /// ------------------------------------------------------------------
    /// <summary>
    /// Set the theme.
    /// </summary>
    /// <param name="e"></param>
    /// ------------------------------------------------------------------
    protected override void OnPreInit(EventArgs e)
    {
        base.OnPreInit(e);
        if (AppSession.User != null)
        {
            this.Theme = "Default";
            List<ThemeName> themeNames = GetThemes();
            foreach (ThemeName themeName in themeNames)
                if (themeName.Value == AppSession.User.ThemeName)
                {
                    this.Theme = themeName.Value;
                    break;
                }

        }
    }


    /// ------------------------------------------------------------------
    /// <summary>
    /// Initialize the page.
    /// </summary>
    /// <param name="e"></param>
    /// ------------------------------------------------------------------
    protected override void OnInit(EventArgs e)
    {
        // insert a hidden field for tracking session view state
        //
        if (this.Form != null)
        {
            ViewStateKey = new TextBox();
            ViewStateKey.ID = "__ViewStateKey__";
            ViewStateKey.Style["display"] = "none";

            if (System.Configuration.ConfigurationManager.AppSettings["LoadTesting"] == "true")
            {
                if (!IsPostBack)
                {
                    //string strHashedPath = Security.HashString(Page.Request.RawUrl);
                    string strHashedPath = Page.Request.RawUrl;
                    ViewStateKey.Text = Security.Encrypt(strHashedPath);
                    DiskCache.Remove(strHashedPath);

                }
            }
            else
            {
                if (!IsPostBack)
                    ViewStateKey.Text = Security.Encrypt(Guid.NewGuid().ToString() + Convert.ToString(DateTime.Now.Ticks, 0x10));
            }
            System.Globalization.CultureInfo ci = System.Threading.Thread.CurrentThread.CurrentUICulture;
            if (ci.TextInfo.IsRightToLeft)
                this.Page.Form.Style[HtmlTextWriterStyle.Direction] = "rtl";

            this.Form.Controls.AddAt(0, ViewStateKey);
        }

        
        base.OnInit(e);
        
        Response.Cache.SetCacheability(HttpCacheability.NoCache);
    }

    
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        if (!IsPostBack)
            InitializeCurrencyCaptions(Page);
        
    }

    /// <summary>
    /// The system automatically replaces all control's caption and headertext containing the "($)" symbol
    /// with the system's base currency symbol.
    /// </summary>
    protected void InitializeCurrencyCaptions(Control c)
    {
        if (c is UIFieldBase)
        {
            if (((UIFieldBase)c).Caption.Contains("($)"))
                ((UIFieldBase)c).Caption = ((UIFieldBase)c).Caption.Replace("($)", "(" + OApplicationSetting.Current.BaseCurrency.CurrencySymbol + ")");
        }
        if (c is GridView)
        {
            foreach (DataControlField f in ((GridView)c).Columns)
                f.HeaderText = f.HeaderText.Replace("($)", "(" + OApplicationSetting.Current.BaseCurrency.CurrencySymbol + ")");
        }
        foreach (Control child in c.Controls)
            InitializeCurrencyCaptions(child);
    }

    
    /// ------------------------------------------------------------------
    /// <summary>
    /// Enumerate the themes available in the system.
    /// </summary>
    /// <returns></returns>
    /// ------------------------------------------------------------------
    protected List<ThemeName> GetThemes()
    {
        string[] themes = Directory.GetDirectories(Page.MapPath("~/App_Themes"));
        List<ThemeName> themeList = new List<ThemeName>();

        foreach (string theme in themes)
        {
            string t = Path.GetFileNameWithoutExtension(theme);
            themeList.Add(new ThemeName(t, t));
        }

        return themeList;
    }


    /// ------------------------------------------------------------------
    /// <summary>
    /// Override the default page state persister to use the Session state
    /// for persistence.
    /// </summary>
    /// <returns></returns>
    /// ------------------------------------------------------------------
    protected override object LoadPageStateFromPersistenceMedium()
    {
        string viewStateKey = Security.Decrypt(Request.Form["__ViewStateKey__"]);
        LosFormatter los = new LosFormatter();
        string value = DiskCache.GetValue(viewStateKey);
        object o = los.Deserialize(value);
        return o;

    }


    /// ------------------------------------------------------------------
    /// <summary>
    /// Override the default page state persister to use the Session state
    /// for persistence.
    /// </summary>
    /// <param name="state"></param>
    /// ------------------------------------------------------------------
    protected override void SavePageStateToPersistenceMedium(object state)
    {
        string viewStateKey = Security.Decrypt(ViewStateKey.Text);
        LosFormatter los = new LosFormatter();
        StringWriter sw = new StringWriter();
        los.Serialize(sw, state);
        DiskCache.Add(viewStateKey, sw.ToString());
    }


    /// <summary>
    /// Modifies the output to show the entire form, if and only if
    /// it has been completely downloaded.
    /// </summary>
    /// <param name="writer"></param>
    protected override void Render(HtmlTextWriter writer)
    {
        if (!Page.Request.RawUrl.Contains("report.aspx"))
        {
            StringWriter sw = new StringWriter();
            HtmlTextWriter hw = new HtmlTextWriter(sw);
            base.Render(hw);

            string s =
                hw.InnerWriter.ToString()
                .Replace("<form", "<form style='display:none' ")
                .Replace("</form>", "</form><script type='text/javascript'>document.forms[0].style.display = ''; </script>");

            writer.Write(s);
        }
        else
        {
            base.Render(writer);
        }
    }


}



public class ThemeName
{
    public string Name;
    public string Value;

    public ThemeName(string name, string value)
    {
        Name = name;
        Value = value;
    }
}
