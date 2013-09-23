using System;
using System.Globalization;
using System.Threading;
using System.ComponentModel;
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
using System.Text;

using Anacle.DataFramework;
using LogicLayer;
using Anacle.UIFramework;

/// <summary>
/// Summary description for apploginreset
/// </summary>
public partial class apploginreset : System.Web.UI.Page
{
    private OUser user = null;

    public apploginreset()
    {
        //
        // TODO: Add constructor logic here
        //
    }


    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);

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

    protected bool ValidateForm()
    {
        bool bResult = true;

        lblUserNameRequired.Visible = false;
        lblEmailRequired.Visible = false;

        if (txtEmail.Text.Trim().Length < 1)
        {
            lblEmailRequired.Visible = true;
            bResult = false;
        }

        if (txtUserLogin.Text.Trim().Length < 1)
        {
            lblUserNameRequired.Visible = true;
            bResult = false;
        }

        if (bResult)
        {
            user = OUser.GetUserByLoginName(txtUserLogin.Text.Trim());

            if (user == null)
            {
                lblResetError.Text = Resources.Errors.User_UserNameNotExist;
                bResult = false;
            }
            else //if user exists
            {
                if (user.UserBase.Email.Trim().Length < 1 ||
                    user.UserBase.Email.Equals(txtEmail.Text.Trim()) == false)
                {
                    lblResetError.Text = Resources.Errors.User_EmailWrong;
                    bResult = false;
                }
                else if (user.IsBanned == 1)
                {
                    lblResetError.Text = Resources.Errors.User_AccountBanned;
                    bResult = false;
                }
                else if (!user.IsPasswordOldEnoughToChange())
                {
                    int intDayToWait = Convert.ToInt32(OApplicationSetting.Current.PasswordMinimumAge) - user.GetPasswordAge();

                    lblResetError.Text = String.Format(Resources.Errors.User_PasswordCannotChange, intDayToWait.ToString());
                    bResult = false;
                }
            }
        }

        return bResult;
    }


    /// <summary>
    /// Resets the user's password.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnResetPassword_Click(object sender, EventArgs e)
    {
        if (ValidateForm())
        {
            user = OUser.GetUserByLoginName(txtUserLogin.Text.Trim());
            user.ResetPassword();
            lblResetError.Text = Resources.Errors.User_PasswordReset;
        }
    }

    protected void btnBack_Click(object sender, EventArgs e)
    {
        Response.Redirect("applogin.aspx", true);
    }
}
