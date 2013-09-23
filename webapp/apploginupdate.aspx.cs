using System;
using System.Globalization;
using System.Threading;
using System.ComponentModel;
using System.Collections.Generic;
using System.ComponentModel.Design;
using System.Data;
using System.Drawing;
using System.Configuration;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.Design;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;

using Anacle.DataFramework;
using LogicLayer;
using Anacle.UIFramework;

/// <summary>
/// Summary description for applogin
/// </summary>
public partial class apploginupdate : System.Web.UI.Page
{
    private OUser user
    {
        get
        {
            return AppSession.User;
        }
    }

    public apploginupdate()
    {
        //
        // TODO: Add constructor logic here
        //
    }

    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);

        if (!IsPasswordUpdatable())
            Response.Redirect("applogin.aspx", true);

        if (!IsPostBack)
        {
            OApplicationSetting applicationSetting = OApplicationSetting.Current;
            tableLoginCell.Style["background-image"] = "url('apploginlogo.aspx?ID=" + applicationSetting.VersionNumber + "')";

            if (applicationSetting.LoginControlsHorizontalAlignment == 0)
                tableLoginCell.Align = "left";
            else if (applicationSetting.LoginControlsHorizontalAlignment == 1)
                tableLoginCell.Align = "center";
            else if (applicationSetting.LoginControlsHorizontalAlignment == 2)
                tableLoginCell.Align = "right";

            if (applicationSetting.LoginControlsVerticalAlignment == 0)
                tableLoginCell.VAlign = "top";
            else if (applicationSetting.LoginControlsVerticalAlignment == 1)
                tableLoginCell.VAlign = "middle";
            else if (applicationSetting.LoginControlsVerticalAlignment == 2)
                tableLoginCell.VAlign = "bottom";
        }
    }


    /// <summary>
    /// Checks if the password is updatable at this juncture.
    /// </summary>
    /// <returns></returns>
    private bool IsPasswordUpdatable()
    {
        return (user != null &&
            (user.HasPasswordExpired() || user.IsPasswordChangeRequired == 1));
    }

    /// <summary>
    /// Validates that the password has been entered correctly.
    /// </summary>
    /// <returns></returns>
    private bool ValidateForm()
    {
        OApplicationSetting applicationSetting = OApplicationSetting.Current;


        bool bResult = true;
        lblPasswordRequired.Visible = false;
        lblConfirmNewPasswordRequired.Visible = false;

        // Check that both text boxes have been filled in.
        //
        if (txtNewPassword.Text == "")
        {
            lblPasswordRequired.Visible = true;
            bResult = false;
        }

        if (txtConfirmNewPassword.Text == "")
        {
            lblConfirmNewPasswordRequired.Visible = true;
            bResult = false;
        }

        // Ensures that both passwords are the same
        //
        if (txtNewPassword.Text.Equals(txtConfirmNewPassword.Text) == false)
        {
            lblPasswordError.Text = Resources.Errors.User_PasswordDifferent;
            bResult = false;
        }

        if (!bResult)
            return false;

        // Ensures that the password adheres to the minimum
        // length requirement.
        //
        if (applicationSetting.PasswordMinimumLength != null &&
            (txtNewPassword.Text.Length < applicationSetting.PasswordMinimumLength.Value ||
            txtConfirmNewPassword.Text.Length < applicationSetting.PasswordMinimumLength.Value))
        {
            lblPasswordError.Text = String.Format(Resources.Errors.User_PasswordMinimumLength,
                applicationSetting.PasswordMinimumLength.Value);
            return false;
        }

        // Ensures that the password has the required
        // valid characters.
        //
        if (!OUserPasswordHistory.ValidatePasswordCharacters(txtNewPassword.Text))
        {
            if (applicationSetting.PasswordRequiredCharacters == 1)
                lblPasswordError.Text = Resources.Errors.User_PasswordMustContainAlphaNumericCharacters;
            else if (applicationSetting.PasswordRequiredCharacters == 2)
                lblPasswordError.Text = Resources.Errors.User_PasswordMustContainAlphaNumericSpecialCharacters;
            return false;
        }

        // Ensures that the password does not exist
        // in the history of passwords.
        //
        string strHashedNewPassword = Security.HashString(txtNewPassword.Text);
        if (OUserPasswordHistory.DoesPasswordExist(user.ObjectID.Value, strHashedNewPassword))
        {
            lblPasswordError.Text = String.Format(Resources.Errors.User_PasswordHistoryExists,
                applicationSetting.PasswordHistoryKept);
            return false;
        }

        return true;
    }


    /// <summary>
    /// Saves the user's new password into the database.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnUpdatePassword_Click(object sender, EventArgs e)
    {
        //validate password
        if (ValidateForm())
        {
            try
            {
                user.SetNewPassword(txtNewPassword.Text, true);
            }
            catch (Exception err)
            {
                lblPasswordError.Text = err.Message;
                return;
            }

            FormsAuthenticationTicket ticket = new FormsAuthenticationTicket(user.UserBase.LoginName, true, 20);

            HttpCookie cookie = new HttpCookie(
                FormsAuthentication.FormsCookieName,
                FormsAuthentication.Encrypt(ticket));
            Response.Cookies.Add(cookie);
            Response.Redirect("apptop.aspx");
        }
    }
}
