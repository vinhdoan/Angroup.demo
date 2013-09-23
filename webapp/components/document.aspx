<%@ Page Language="C#" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<%@ Import Namespace="System" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Web" %>
<%@ Import Namespace="System.Web.UI" %>
<%@ Import Namespace="System.Web.UI.WebControls" %>
<%@ Import Namespace="System.ComponentModel" %>
<%@ Import Namespace="Anacle.DataFramework" %>
<%@ Import Namespace="LogicLayer" %>
<%@ Import Namespace="Anacle.UIFramework" %>
<%@ Import Namespace="System.Globalization" %>
<%@ Import Namespace="System.Threading" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Diagnostics" %>

<script runat="server">
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
        if (AppSession.User != null &&
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


    bool foundMultiple = false;
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);

        if (!IsPostBack)
        {
            //rachel. view document template
            if (Request["templateID"] != null)
            {
                ODocumentTemplate template = TablesLogic.tDocumentTemplate[new Guid(Security.DecryptFromHex(Request["templateID"]).ToString())];
                if (template.FileBytes == null || template.FileBytes.Length == 0)
                    return;
                try
                {
                    object persistentObject = Session[Request["session"]];
                    byte[] fileBytes = DocumentGenerator.GenerateDocument(template, persistentObject);
                    if (fileBytes != null)
                    {
                        // 2011.08.31, Kien Trung
                        // temporarily force filename to be downloaded to objectnumber
                        // no other solution yet. 
                        // 
                        //string filename = template.FileDescription;
                        string filename = ((LogicLayerPersistentObject)persistentObject).ObjectNumber;
                        
                        // 2011.08.11, Kien Trung
                        // FIXED: Clear headers to bypass microsoft IE bug 
                        // for downloading attachment on ssl (https)
                        //
                        Response.ClearHeaders();
                        Response.ContentType = template.OutputContentMIMEType;
                        Response.ContentEncoding = Encoding.Default;
                        Response.AddHeader("content-disposition", (template.OutputFormat == DocumentOutputFormat.Static ? "inline;" : "attachment;") + " filename=" + filename.Replace(" ", "_") + "." + template.OutputFileExtension);

                        Response.BinaryWrite(fileBytes);
                        Response.End();
                    }
                        

                }
                catch (Exception ex)
                {
                    labelCaption.Text = Resources.Errors.DocumentTemplate_UnableToGenerate + ex.Message;
                }
            }
            else
            {
                if (Request["filekey"] != null)
                {
                    // Writes the file directly from the disk cache into
                    // the response stream. This saves the need load a
                    // potentially very huge file into memory, only to have
                    // it sent down into the HTTP response stream and 
                    // freed up.
                    //
                    Response.ClearHeaders();
                    Response.WriteFile(DiskCache.GetFilePath(Request["filekey"]));
                    if (Request["filename"] != null)
                        Response.AddHeader("content-disposition", "attachment; filename=" + Request["filename"].Replace(" ", "_"));
                    if (Request["mimetype"] != null)
                        Response.ContentType = Request["mimetype"];
                    Response.End();
                }
                if (Request["filepath"] != null)
                {
                    // Writes the file directly from file specified in the file path into
                    // the response stream. This saves the need load a
                    // potentially very huge file into memory, only to have
                    // it sent down into the HTTP response stream and 
                    // freed up.
                    //
                    Response.ClearHeaders();
                    Response.WriteFile(Request["filepath"]);
                    if (Request["filename"] != null)
                        Response.AddHeader("content-disposition", "attachment; filename=" + Request["filename"].Replace(" ", "_"));
                    if (Request["mimetype"] != null)
                        Response.ContentType = Request["mimetype"];
                    Response.End();
                }
            }
        }
    }

    public string WKHtmlToPdf(string Url)
    {
        var p = new Process();

        string switches = "";
        switches += "--print-media-type ";
        switches += "--margin-top 10mm --margin-bottom 10mm --margin-right 10mm --margin-left 10mm ";
        switches += "--page-size Letter ";
        // waits for a javascript redirect it there is one
        switches += "--redirect-delay 100";

        // Utils.GenerateGloballyUniuqueFileName takes the extension from
        // basically returns a filename and prepends a GUID to it (and checks for some other stuff too)
        string fileName = ConfigurationManager.AppSettings["ReportTempFolder"] + Guid.NewGuid().ToString() + ".pdf";

        var startInfo = new ProcessStartInfo
        {
            FileName = Server.MapPath("..\\wkhtmltopdf\\wkhtmltopdf.exe"),
            Arguments = switches + " " + Path.GetFileName(Url) + " \"" + fileName + "\"",
            UseShellExecute = false, // needs to be false in order to redirect output
            RedirectStandardOutput = true,
            RedirectStandardError = true,
            RedirectStandardInput = true, // redirect all 3, as it should be all 3 or none
            WorkingDirectory = Path.GetDirectoryName(Url)
        };
        p.StartInfo = startInfo;
        p.Start();

        // doesn't work correctly...
        // read the output here...
        // string output = p.StandardOutput.ReadToEnd();

        //  wait n milliseconds for exit (as after exit, it can't read the output)
        p.WaitForExit(60000);

        // read the exit code, close process
        int returnCode = p.ExitCode;
        p.Close();

        // if 0, it worked
        //return (returnCode == 0) ? fileName : null;
        return fileName;
    }

    protected override void OnPreRender(EventArgs e)
    {
        base.OnPreRender(e);
        this.messageDiv.Visible = labelCaption.Text != "";
    }
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>Untitled Page</title>
</head>
<body>
    <form id="form1" runat="server">
        <div>
            <asp:panel runat="server" CssClass='object-message' ID="messageDiv" Style="width: 100%">
                <asp:Label runat='server' ID='labelCaption' EnableViewState="false" ForeColor="Red"
                    Font-Bold="True" meta:resourcekey="labelMessageResource1"></asp:Label>
            </asp:panel>
        </div>
    </form>
</body>
</html>
