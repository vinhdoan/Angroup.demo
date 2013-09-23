<%@ WebService Language="C#" Class="SearchList" %>

using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Services;
using Anacle.UIFramework;

/// <summary>
/// Summary description for SearchList
/// </summary>
[WebService(Namespace = "http://tempuri.org/")]
[WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
[System.Web.Script.Services.ScriptService]
public class SearchList : System.Web.Services.WebService
{
    public SearchList()
    {
    }

    [System.Web.Services.WebMethod]
    [System.Web.Script.Services.ScriptMethod]
    public string GetHtml(string contextKey)
    {
        return UISearchableDropDownList.ProcessSearchList(contextKey);
    }
}

