<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" meta:resourcekey="PageResource1"
    UICulture="auto" %>

<%@ Register Src="~/components/menu.ascx" TagPrefix="web" TagName="menu" %>
<%@ Register Src="~/components/objectpanel.ascx" TagPrefix="web" TagName="object" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Collections" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="Anacle.DataFramework" %>
<%@ Import Namespace="LogicLayer" %>
<%@ Import Namespace="System.IO" %>
<%@ Register assembly="Anacle.UIFramework" namespace="Anacle.UIFramework" tagprefix="cc1" %>
<script runat="server">
    /// <summary>
    /// Populates the form controls.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="obj"></param>
    protected void panel_PopulateForm(object sender, EventArgs e)
    {
        OCapitalandCompany company = panel.SessionObject as OCapitalandCompany;
        panel.ObjectPanel.BindObjectToControls(company);
        if (company!=null && company.LogoFile !=null && company.LogoFile.Length >0) {
            Session["Logo"] = company.LogoFile;
            Image_Logo.ImageUrl = "loadlogo.aspx?";
            Image_Logo.Visible = true;
        }
        
    }


    /// <summary>
    /// Validates and saves the company object into the database.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void panel_ValidateAndSave(object sender, EventArgs e)
    {
        using (Connection c = new Connection())
        {
            OCapitalandCompany company = (OCapitalandCompany)panel.SessionObject;
            panel.ObjectPanel.BindControlsToObject(company);
            // Save
            // 
            company.Save();
            c.Commit();
        }
    }




  

    /// <summary>
    /// Hides/shows controls
    /// </summary>
    /// <param name="e"></param>
    protected override void OnPreRender(EventArgs e)
    {
        base.OnPreRender(e);
        OCapitalandCompany company = (OCapitalandCompany)panel.SessionObject;
        if (company != null && company.LogoFile != null && company.LogoFile.Length > 0)
            Image_Logo.Visible = true;
        else
            Image_Logo.Visible = false;
        //if (lbFilename.Text != "")
        //{
        //    this.buttonDownload.Visible = true;
        //}
        //else
        //{
        //    this.buttonDownload.Visible = false;
        //}

    }

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);

        // Register the buttonUpload button to force a full
        // postback whenever a file is uploaded.
        //
        if (Page is UIPageBase)
        {
            ((UIPageBase)Page).ScriptManager.RegisterPostBackControl(buttonUpload);
        }
    }

    protected void buttonUpload_Click(object sender, EventArgs e)
    {
        if (InputFile.PostedFile != null && InputFile.PostedFile.ContentLength > 0)
        {
            
            //if (InputFile.PostedFile.ContentLength > 4096000)
            //{
            //    panel.Message = "Attached Document should not be more than 4 megabytes.";

            //}
            //else
            //{
                OCapitalandCompany company = (OCapitalandCompany)panel.SessionObject;
                panel.ObjectPanel.BindControlsToObject(company);

                byte[] fileBytes = new byte[InputFile.PostedFile.ContentLength];
                InputFile.PostedFile.InputStream.Position = 0;
                InputFile.PostedFile.InputStream.Read(fileBytes, 0, fileBytes.Length);

                company.LogoFile = fileBytes;
                company.LogoFileName = Path.GetFileName(InputFile.PostedFile.FileName);
                panel.ObjectPanel.BindObjectToControls(company);
                if (company != null && company.LogoFile != null && company.LogoFile.Length > 0)
                {
                    Session["Logo"] = fileBytes;
                    Image_Logo.ImageUrl = "loadlogo.aspx?";
                }
                //if (lbFilename.Text != "")
                //{
                //    this.buttonDownload.Visible = true;
                //}
                //else
                //{
                //    this.buttonDownload.Visible = false;
                //}
            //}
        }
    }
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <meta http-equiv="pragma" content="no-cache" />
    <link href="../../App_Themes/Corporate/StyleSheet.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
    <ui:UIObjectPanel runat="server" ID="panelMain" BorderStyle="NotSet" 
        meta:resourcekey="panelMainResource1">
        <web:object runat="server" ID="panel" Caption="Company" BaseTable="tCapitalandCompany" meta:resourcekey="panelResource1"
            OnPopulateForm="panel_PopulateForm" OnValidateAndSave="panel_ValidateAndSave">
        </web:object>
        <div class="div-main">
            <ui:UITabStrip runat="server" ID="tabObject" 
                meta:resourcekey="tabObjectResource1" BorderStyle="NotSet">
                <ui:UITabView runat="server" ID="tabDetails" Caption="Details" 
                    meta:resourcekey="tabDetailsResource1" BorderStyle="NotSet">
                    <web:base runat="server" ID="objectBase" ObjectNumberVisible="false" ObjectNameCaption="Company Name"
                        meta:resourcekey="objectBaseResource1"></web:base>
                    <ui:UIFieldTextBox runat="server" ID="txtDesc" PropertyName="Description" MaxLength="255"
                        Caption="Description" InternalControlWidth="95%" 
                        meta:resourcekey="txtDescResource1"/>
                    <ui:UIFieldTextBox runat="server" ID="textAddress" PropertyName="Address" 
                        Caption="Address" MaxLength="255" InternalControlWidth="95%" 
                        meta:resourcekey="textAddressResource1" />
                    <ui:UIFieldTextBox runat="server" ID="txtCountry" PropertyName="Country" MaxLength="255" 
                        Caption="Country" Span="Half" InternalControlWidth="95%" 
                        meta:resourcekey="txtCountryResource1"/>
                    <ui:UIFieldTextBox runat="server" ID="txtPostalCode" PropertyName="PostalCode"
                        Caption="Postal Code" Span="Half" InternalControlWidth="95%" 
                        meta:resourcekey="txtPostalCodeResource1" />
                    <ui:UIFieldTextBox runat="server" ID="txtPhone" PropertyName="PhoneNo"
                        Caption="Phone No." Span="Half" InternalControlWidth="95%" 
                        meta:resourcekey="txtPhoneResource1"  />
                    <ui:UIFieldTextBox runat="server" ID="txtFax" PropertyName="FaxNo"
                        Caption="Fax No." Span="Half" InternalControlWidth="95%" 
                        meta:resourcekey="txtFaxResource1" />
                    <ui:UIFieldTextBox runat="server" ID="uifieldstring9" PropertyName="ContactPerson"
                        Caption="Contact Person" Span="Half" MaxLength="255" 
                        InternalControlWidth="95%" meta:resourcekey="uifieldstring9Resource1" />
                    <ui:UIFieldTextBox runat="server" ID="uifieldstring10" PropertyName="RegNo"
                        Caption="RegNo" Span="Half" InternalControlWidth="95%" 
                        meta:resourcekey="uifieldstring10Resource1"/>
                    <ui:UIFieldCheckBox runat="server" ID="IsDeactivated" PropertyName="IsDeactivated"
                        Caption="Is Deactivated" Span="Half" InternalControlWidth="95%"></ui:UIFieldCheckBox>
                     <ui:UIFieldTextBox runat="server" ID="txtPaymentName" PropertyName="PaymentName"
                        Caption="Payment Name" Span="Half" MaxLength="255" 
                        InternalControlWidth="95%" meta:resourcekey="txtPaymentNameResource1" />
                    <br />
                    <ui:UISeparator runat='server' ID="UISeparator1" 
                        meta:resourcekey="UISeparator1Resource1" />
                    <ui:UIPanel runat="server" ID="panelUploadFile" BorderStyle="NotSet" 
                        meta:resourcekey="panelUploadFileResource1">
                            <ui:UIFieldInputFile ID="InputFile" runat="server" Caption="Logo Path" 
                                meta:resourcekey="InputFileResource1" />
                            <table cellpadding="0" cellspacing="0" border="0" width="100%">
                                <tr>
                                    <td style="width: 124px">
                                    </td>
                                    <td>
                                        <ui:UIButton runat="server" Text="Upload File" ID="buttonUpload"
                                            ImageUrl="~/images/document-attach.gif" OnClick="buttonUpload_Click" 
                                            meta:resourcekey="buttonUploadResource1" />
                                    </td>
                                </tr>
                            </table>
                            <ui:UISeparator runat="server" ID="Separator1" Caption="Uploaded File" 
                                meta:resourcekey="Separator1Resource2" />
                            <ui:UIFieldLabel runat="server" ID="lbFilename" Caption="File Name" PropertyName="LogoFileName"
                                Span="Half" DataFormatString="" meta:resourcekey="lbFilenameResource1"></ui:UIFieldLabel>
                            <ui:UIButton runat="server" Visible="False" Text="Download File" ImageUrl="~/images/icon-savesmall.gif"
                                ID="buttonDownload" meta:resourcekey="buttonDownloadResource1"/>
                        <br />
                        <br />
                        <asp:Image ID="Image_Logo" runat="server" meta:resourcekey="Image_LogoResource1" />
                        </ui:UIPanel>
                </ui:UITabView>
                <ui:UITabView runat="server" ID="tabMemo" Caption="Memo" 
                    meta:resourcekey="tabMemoResource1" BorderStyle="NotSet">
                    <web:memo ID="Memo1" runat="server"></web:memo>
                </ui:UITabView>
                <ui:UITabView runat="server" ID="tabAttachments" Caption="Attachments" 
                    meta:resourcekey="tabAttachmentsResource1" BorderStyle="NotSet">
                    <web:attachments runat="server" ID="attachments"></web:attachments>
                </ui:UITabView>
            </ui:UITabStrip>
        </div>
    </ui:UIObjectPanel>
    </form>
</body>
</html>
