//========================================================================
// $Product: Anacle Enterprise Asset Management
// $Version: 5.0
//
// Copyright 2006 (c) Anacle Systems Pte. Ltd.
// All rights reserved.
//========================================================================
using System;
using System.Data;
using System.Configuration;
using System.Collections.Generic;

using System.Web;

using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;
using Anacle.DataFramework;
using LogicLayer;

/// <summary>
/// Summary description for Window
/// </summary>
public class Window
{
    public const int popupWidth = 1000;
    public const int popupHeight = 680;

    public const string JavaScriptStart = "<script type='text/javascript'>";
    public const string JavaScriptEnd = "</script>";

    /// <summary>
    /// 2011 03 29
    /// Kien Trung
    /// Escape the special characters in the encoded string
    /// </summary>
    /// <param name="path"></param>
    /// <returns></returns>
    public static string escMap(string path)
    {
        string[] esc = {" ","<",">","#","{","}","|","\\","^",
                     "~","[", "]","\'",";","/","?",":","@","=",
                     "&","$"};

        string[] value = {"%20","%3C","%3E","%23","%7B",
                          "%7D","%7C","%5C","%5E","%7E","%5B",
                          "%5D","%60","%3B","%2F","%3F","%3A",
                          "%40","%3D","%26","%24"};

        for (int i = 0; i < 21; i++)
        {
            if (path.Contains(esc[i]))
            {
                path = path.Replace(esc[i], value[i]);
            }
        }

        return path;

    }

    /// <summary>
    /// Emits javascript to the page.
    /// </summary>
    /// <param name="s"></param>
    public static void WriteJavascript( string s )
    {
        ScriptManager.RegisterClientScriptBlock(
            HttpContext.Current.Handler as Page, typeof(Page),
            "output" + Guid.NewGuid(), JavaScriptStart + s + JavaScriptEnd, false);
    }


    /// <summary>
    /// Emits javascript to close the current browser window.
    /// </summary>
    public static void Close()
    {
        WriteJavascript( "window.close();" );
    }


    /// <summary>
    /// Pop-up a page that allows the user to download a file
    /// given the binary image of that file.
    /// </summary>
    /// <param name="url"></param>
    /// <param name="target"></param>
    public static void Download(byte[] binaryImage, string fileName, string contentType)
    {
        Page page = HttpContext.Current.Handler as Page;
        Anacle.UIFramework.DiskCache.Add("FILEBINARY", binaryImage);

        // 2011 03 29
        // Kien Trung
        // Escape special characters of filename.
        fileName = escMap(fileName);

        // pop-up document in a new window
        Window.Open(page.Request.ApplicationPath + "/components/document.aspx" +
            "?filename=" + HttpUtility.UrlEncode(fileName) +
            "&filekey=FILEBINARY" +
            "&mimetype=" + HttpUtility.UrlEncode(contentType),
            "document");
    }


    /// <summary>
    /// Pop-up a page that allows the user to download a file
    /// given the text of that file.
    /// </summary>
    /// <param name="url"></param>
    /// <param name="target"></param>
    public static void Download(string textContent, string fileName, string contentType)
    {
        Page page = HttpContext.Current.Handler as Page;
        Anacle.UIFramework.DiskCache.Add("FILETEXT", textContent);

        // 2011 03 29
        // Kien Trung
        // Escape special characters of filename.
        fileName = escMap(fileName);

        // pop-up document in a new window
        Window.Open(page.Request.ApplicationPath + "/components/document.aspx" +
            "?filename=" + HttpUtility.UrlEncode(fileName) +
            "&filekey=FILETEXT" +
            "&mimetype=" + HttpUtility.UrlEncode(contentType),
            "document");
    }


    /// <summary>
    /// Pop-up a page that allows the user to download a file
    /// given the file path of the file (relative to the
    /// application's physical directory).
    /// </summary>
    /// <param name="url"></param>
    /// <param name="target"></param>
    public static void DownloadFile(string filePath, string fileName, string contentType)
    {
        Page page = HttpContext.Current.Handler as Page;

        string filename = System.IO.Path.GetFileName(filePath);

        // 2011 03 29
        // Kien Trung
        // Bug fix
        // Escape special characters of filename.
        filename = escMap(filename);

        // pop-up document in a new window
        Window.Open(page.Request.ApplicationPath + "/components/document.aspx" +
            "?filename=" + HttpUtility.UrlEncode(fileName) +
            "&filepath=" + HttpUtility.UrlEncode(filePath) +
            "&mimetype=" + HttpUtility.UrlEncode(contentType),
            "document");
    }


    /// <summary>
    /// Emits javascript to open a URL in a new browser window.
    /// </summary>
    /// <param name="url">The URL to open.</param>
    /// <param name="target">The target window to open. Leave blank to open
    public static void Open(string url, string target)
    {
        WriteJavascript("window.open('" + url + "', '" + target + "','location=no,status=yes,menubar=no,toolbar=no,resizable=yes,scrollbars=yes');");
    }

    /// <summary>
    /// Emits javascript to open a URL in a new browser window.
    /// </summary>
    /// <param name="url">The URL to open.</param>
    /// <param name="target">The target window to open. Leave blank to open
    public static void Open(string url, string target, string additionalString)
    {
        WriteJavascript("window.open('" + url + "', '" + target + "','" + additionalString + "');");
    }


    /// <summary>
    /// Emits javascript to open a URL in the same browser window.
    /// </summary>
    /// <param name="url">The URL to open.</param>
    public static void Open(string url)
    {
        WriteJavascript( "window.open('" + url + "');" );
    }


    /// <summary>
    /// Emits javascript to open the edit page in NEW (create) mode.
    /// </summary>
    /// <param name="page">The Page object.</param>
    /// <param name="objectType">The type of object.</param>
    /// <param name="additionalQueryString">Additional query strings to be
    /// appended to the end of the URL.</param>
    public static void OpenAddObjectPage(Page page, string objectType, string additionalQueryString)
    {
        OFunction function = OFunction.GetFunctionByObjectType(objectType);
        Window.Open(
            page.ResolveUrl(function.EditUrl) + "?ID=" +
            HttpUtility.UrlEncode(Security.Encrypt("NEW:")) +
            "&TYPE=" + HttpUtility.UrlEncode(Security.Encrypt(objectType)) +
            "&" + additionalQueryString, "AnacleEAM_Window");
    }


    /// <summary>
    /// Emits javascript to open the edit page in NEW (create) mode, but
    /// the edit page does not automatically create the object.
    /// <para>
    /// </para>
    /// NOTE: DO NOT pass in N=? as part of the querystring, as this will
    /// cause the new object passed in to be lost.
    /// </summary>
    /// <param name="page">The Page object.</param>
    /// <param name="newObject">The new PersistentObject created outside of the object panel.</param>
    /// <param name="additionalQueryString">Additional query strings to be
    /// appended to the end of the URL.</param>
    public static void OpenAddObjectPage(Page page, PersistentObject newObject, string additionalQueryString)
    {
        page.Session["::SessionObject::"] = newObject;
        OFunction function = OFunction.GetFunctionByObjectType(newObject.GetType().BaseType.Name);
        Window.Open(
            page.ResolveUrl(function.EditUrl) + "?ID=" +
            HttpUtility.UrlEncode(Security.Encrypt("NEW2:")) +
            "&TYPE=" + HttpUtility.UrlEncode(Security.Encrypt(newObject.GetType().BaseType.Name)) +
            "&" + additionalQueryString, "Simplism_Window");
    }


    /// <summary>
    /// Emits javascript to open the edit page in EDIT mode.
    /// </summary>
    /// <param name="page">The Page object.</param>
    /// <param name="objectType">The type of object.</param>
    /// <param name="additionalQueryString">Additional query strings to be
    /// appended to the end of the URL.</param>
    public static void OpenEditObjectPage(Page page, string objectType, string unencryptedGuid, string additionalQueryString)
    {
        OFunction function = OFunction.GetFunctionByObjectType(objectType);
        Window.Open(
            page.ResolveUrl(function.EditUrl) + "?ID=" +
            HttpUtility.UrlEncode(Security.Encrypt("EDIT:" + unencryptedGuid)) +
            "&TYPE=" + HttpUtility.UrlEncode(Security.Encrypt(objectType)) +
            "&" + additionalQueryString, "AnacleEAM_Window");
    }


    /// <summary>
    /// Emits javascript to open the edit page in VIEW (read-only) mode.
    /// </summary>
    /// <param name="page">The Page object.</param>
    /// <param name="objectType">The type of object.</param>
    /// <param name="additionalQueryString">Additional query strings to be
    /// appended to the end of the URL.</param>
    public static void OpenViewObjectPage(Page page, string objectType, string unencryptedGuid, string additionalQueryString)
    {
        OFunction function = OFunction.GetFunctionByObjectType(objectType);
        Window.Open(
            page.ResolveUrl(function.EditUrl) + "?ID=" +
            HttpUtility.UrlEncode(Security.Encrypt("VIEW:" + unencryptedGuid)) +
            "&TYPE=" + HttpUtility.UrlEncode(Security.Encrypt(objectType)) + 
            "&" + additionalQueryString, "AnacleEAM_Window");
    }

    /// <summary>
    /// Emits javascript to open the edit page in VIEW (read-only) mode in new window.
    /// </summary>
    /// <param name="page">The Page object.</param>
    /// <param name="objectType">The type of object.</param>
    /// <param name="additionalQueryString">Additional query strings to be
    /// appended to the end of the URL.</param>
    public static void OpenViewObjectPageInNewWindow(Page page, string objectType, string unencryptedGuid, string additionalQueryString)
    {
        OFunction function = OFunction.GetFunctionByObjectType(objectType);
        Window.Open(
            page.ResolveUrl(function.EditUrl) + "?N=" + HttpUtility.UrlEncode(Security.Encrypt("NewView")) + "&ID=" +
            HttpUtility.UrlEncode(Security.Encrypt("VIEW:" + unencryptedGuid)) +
            "&TYPE=" + HttpUtility.UrlEncode(Security.Encrypt(objectType)) +
            "&" + additionalQueryString, "AnacleEAM_Window_New");

    }
    /// <summary>
    /// Represents the current browser window's Opener object.
    /// This Opener object exposes only a subset of the methods
    /// of its javascript counterpart, and contains additional
    /// set of methods for populating and refreshing the opener.
    /// </summary>
    private static Opener opener = new Opener();

    /// <summary>
    /// Gets the current browser window's opener object.
    /// This Opener object exposes only a subset of the methods
    /// of its javascript counterpart, and contains additional
    /// set of methods for populating and refreshing the opener.
    /// </summary>
    public static Opener Opener
    {
        get
        {
            return opener;
        }
    }

    /// <summary>
    /// This method returns a data table to the opener page for the
    /// MultiSelectGrid.
    /// </summary>
    /// <param name="dt"></param>
    [Obsolete]
    public static void ReturnDataTable(Page page, DataTable dt)
    {
        if (page.Request["CONTROLID"] != null)
        {
            page.Session["MASSADD"] = dt;
            string controlId = Security.Decrypt(page.Request["CONTROLID"]);
            Window.WriteJavascript(
                "if( window.top.opener.document.getElementById('" + controlId + "').onchange )\n" +
                "  window.top.opener.document.getElementById('" + controlId + "').onchange();\n" +
                "window.top.close();\n");
        }
    }
}


/// <summary>
/// Represents the current browser window's Opener object.
/// This Opener object exposes only a subset of the methods
/// of its javascript counterpart, and contains additional
/// set of methods for populating and refreshing the opener.
/// </summary>
public class Opener
{
    /// <summary>
    /// Populates two HTML input elements in the opener with
    /// the specified Guid and a text name.
    /// </summary>
    /// <param name="page">The current Page object.</param>
    /// <param name="value">A GUID value to set to the control whose ID is passed in via the 'vid' query string.</param>
    /// <param name="objectName">A text to set to the control whose ID is passed in via the 'tid' query string.</param>
    public void Populate(string value)
    {
        Page page = HttpContext.Current.Handler as Page;
        if (page != null)
        {
            string vid = page.Request["vid"];

            Window.WriteJavascript(
                "window.top.opener.document.getElementById('" + vid + "').value = '" + value.Replace("\\", "\\\\").Replace("'", "\\'") + "';\n" +
                "if( window.top.opener.document.getElementById('" + vid + "').onchange )\n" +
                "  window.top.opener.document.getElementById('" + vid + "').onchange();\n" +
                "window.top.close();\n");
        }
    }


    /// <summary>
    /// Emits a javascript to click on a link button in the
    /// parent opener. 
    /// <para></para>
    /// NOTE: You must supply the ClientID of the UIButton
    /// (which is usually the same as the ID of the UIButton,
    /// if the UIButton has not been placed within Repeaters,
    /// TemplateColumns, .ascx controls or any other form 
    /// of naming containers).
    /// </summary>
    /// <param name="page"></param>
    /// <param name="buttonId"></param>
    public void ClickUIButton(string buttonId)
    {
        buttonId = buttonId + "_bt";
        Window.WriteJavascript(
            "if( window.top && " +
            "window.top.opener && " +
            "(window.top.opener.closed == false) && " +
            "window.top.opener.document && " +
            "window.top.opener.document.getElementById('" + buttonId + "') && " +
            "window.top.opener.document.getElementById('" + buttonId + "').onclick ) " +
            "window.top.opener.document.getElementById('" + buttonId + "').onclick();");
    }


    /// <summary>
    /// Emits a javascript to get the opener to open a new window.
    /// </summary>
    /// <param name="url"></param>
    /// <param name="target"></param>
    public void Open(string url, string target)
    {
        Window.WriteJavascript(
            "if(window.top && window.top.opener && window.top.opener.open && (window.top.opener.closed == false)) window.top.opener.open('" + url + "', '" + target + "');");
    }


    /// <summary>
    /// Emits a javascript to get to opener to refresh itself.
    /// </summary>
    public void Refresh()
    {
        Window.WriteJavascript(
            "if( window.top && window.top.opener && (window.top.opener.closed == false) && window.top.opener.Refresh ) window.top.opener.Refresh();");
    }


    /// <summary>
    /// Emits a javascript to get the opener and the opener's opener to
    /// refresh themselves.
    /// </summary>
    public void Refresh_ThreeLevel()
    {
        Window.WriteJavascript(
            "if( window.top && window.top.opener && (window.top.opener.closed == false) && window.top.opener.top && window.top.opener.top.opener && (window.top.opener.top.opener.closed == false) && window.top.opener.top.opener.Refresh ) window.top.opener.top.opener.Refresh();");
    }

    /// <summary>
    /// Emits a javascript to get to opener to refresh itself.
    /// </summary>
    /// <param name="id"></param>
    [Obsolete]
    public void Refresh(string id)
    {
        Window.WriteJavascript(
            "if( window.top && window.top.opener && (window.top.opener.closed == false) && window.top.opener.RefreshTreeByID ) window.top.opener.RefreshTreeByID('" + id + "');");
    }
}


/// <summary>
/// Contains a method to create a new query string that can be
/// appended to the end of a URL.
/// </summary>
public class QueryString
{
    /// <summary>
    /// Creates and returns a new name/value pair formatted 
    /// as part of a query string.
    /// </summary>
    /// <param name="key">The key of the query string item.</param>
    /// <param name="value">The value of the query string item.</param>
    /// <returns>Returns the string '{name}={value}&'</returns>
    public static string New(string key, string value)
    {
        return key + "=" + HttpUtility.UrlEncode(value) + "&";
    }
}
