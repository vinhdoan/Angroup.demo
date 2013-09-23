<%@ Page Language="C#" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<script runat="server">
    
    /// <summary>
    /// Set the page's theme.
    /// </summary>
    /// <param name="e"></param>
    protected override void OnPreInit(EventArgs e)
    {
        base.OnPreInit(e);

        this.Theme = Request["THEME"];
    }

</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <style type="text/css">
        .menu_mainMenu_0
        {
            background-color: white;
            visibility: hidden;
            display: none;
            position: absolute;
            left: 0px;
            top: 0px;
        }
        .menu_mainMenu_1
        {
            text-decoration: none;
        }
        .menu_mainMenu_2
        {
        }
        .menu_mainMenu_3
        {
            border-style: none;
        }
        .menu_mainMenu_4
        {
        }
        .menu_mainMenu_5
        {
            border-style: none;
        }
        .menu_mainMenu_6
        {
        }
        .menu_mainMenu_7
        {
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
    <div>
        <table cellpadding="0" cellspacing="0" border="0" style="width: 100%;" class="menu">
            <tr class="menu-top">
                <td>
                    &nbsp;
                    <asp:Label runat="server" ID="labelUserName">John Doe</asp:Label>
                    &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;
                    <img id="menu_imageEditProfile" src="../../images/user_edit.gif" align="absmiddle"
                        style="border-width: 0px;" />
                    &nbsp;
                    <asp:Label runat="server" ID="labelEditProfile">Edit Profile</asp:Label>
                    &nbsp;
                    <img id="menu_imageLogout" src="../../images/logout.gif" align="absmiddle" style="border-width: 0px;" />
                    <asp:Label runat="server" ID="label1">Logout</asp:Label>
                    &nbsp; &nbsp;
                </td>
            </tr>
            <tr>
                <td valign="top" class="menu-main">
                    <table id="menu_mainMenu" class="menu_mainMenu_2" cssselectorclass="menu" cellpadding="0"
                        cellspacing="0" border="0">
                        <tr>
                            <td id="menu_mainMenun0">
                                <table class="menu-staticitem menu_mainMenu_4" cellpadding="0" cellspacing="0" border="0"
                                    width="100%">
                                    <tr>
                                        <td style="white-space: nowrap;">
                                            <a class="menu_mainMenu_1 menu-staticitem menu_mainMenu_3" href="home.aspx" target="frameBottom"
                                                style="border-style: none; font-size: 1em;">
                                                <div>
                                                    Home</div>
                                            </a>
                                        </td>
                                    </tr>
                                </table>
                            </td>
                            <td style="width: 3px;">
                            </td>
                            <td id="menu_mainMenun1">
                                <table class="menu-staticitem menu_mainMenu_4" cellpadding="0" cellspacing="0" border="0"
                                    width="100%">
                                    <tr>
                                        <td style="white-space: nowrap;">
                                            <a class="menu_mainMenu_1 menu-staticitem menu_mainMenu_3" href="#" style="border-style: none;
                                                font-size: 1em; cursor: text;">
                                                <div>
                                                    Analysis</div>
                                            </a>
                                        </td>
                                    </tr>
                                </table>
                            </td>
                            <td style="width: 3px;">
                            </td>
                            <td id="menu_mainMenun2">
                                <table class="menu-staticitem menu_mainMenu_4" cellpadding="0" cellspacing="0" border="0"
                                    width="100%">
                                    <tr>
                                        <td style="white-space: nowrap;">
                                            <a class="menu_mainMenu_1 menu-staticitem menu_mainMenu_3" href="#" style="border-style: none;
                                                font-size: 1em; cursor: text;">
                                                <div>
                                                    Admin</div>
                                            </a>
                                        </td>
                                    </tr>
                                </table>
                            </td>
                            <td style="width: 3px;">
                            </td>
                            <td id="menu_mainMenun3">
                                <table class="menu-staticitem menu_mainMenu_4" cellpadding="0" cellspacing="0" border="0"
                                    width="100%">
                                    <tr>
                                        <td style="white-space: nowrap;">
                                            <a class="menu_mainMenu_1 menu-staticitem menu_mainMenu_3" href="#" style="border-style: none;
                                                font-size: 1em; cursor: text;">
                                                <div>
                                                    Asset</div>
                                            </a>
                                        </td>
                                    </tr>
                                </table>
                            </td>
                            <td style="width: 3px;">
                            </td>
                            <td id="menu_mainMenun4">
                                <table class="menu-staticitem menu_mainMenu_4" cellpadding="0" cellspacing="0" border="0"
                                    width="100%">
                                    <tr>
                                        <td style="white-space: nowrap;">
                                            <a class="menu_mainMenu_1 menu-staticitem menu_mainMenu_3" href="#" style="border-style: none;
                                                font-size: 1em; cursor: text;">
                                                <div>
                                                    Budget</div>
                                            </a>
                                        </td>
                                    </tr>
                                </table>
                            </td>
                            <td style="width: 3px;">
                            </td>
                            <td id="menu_mainMenun5">
                                <table class="menu-staticitem menu_mainMenu_4" cellpadding="0" cellspacing="0" border="0"
                                    width="100%">
                                    <tr>
                                        <td style="white-space: nowrap;">
                                            <a class="menu_mainMenu_1 menu-staticitem menu_mainMenu_3" href="#" style="border-style: none;
                                                font-size: 1em; cursor: text;">
                                                <div>
                                                    Report Builder</div>
                                            </a>
                                        </td>
                                    </tr>
                                </table>
                            </td>
                            <td style="width: 3px;">
                            </td>
                            <td id="menu_mainMenun6">
                                <table class="menu-staticitem menu_mainMenu_4" cellpadding="0" cellspacing="0" border="0"
                                    width="100%">
                                    <tr>
                                        <td style="white-space: nowrap;">
                                            <a class="menu_mainMenu_1 menu-staticitem menu_mainMenu_3" href="#" style="border-style: none;
                                                font-size: 1em; cursor: text;">
                                                <div>
                                                    Service</div>
                                            </a>
                                        </td>
                                    </tr>
                                </table>
                            </td>
                            <td style="width: 3px;">
                            </td>
                            <td id="menu_mainMenun7">
                                <table class="menu-staticitem menu_mainMenu_4" cellpadding="0" cellspacing="0" border="0"
                                    width="100%">
                                    <tr>
                                        <td style="white-space: nowrap;">
                                            <a class="menu_mainMenu_1 menu-staticitem menu_mainMenu_3" href="#" style="border-style: none;
                                                font-size: 1em; cursor: text;">
                                                <div>
                                                    Vendor</div>
                                            </a>
                                        </td>
                                    </tr>
                                </table>
                            </td>
                            <td style="width: 3px;">
                            </td>
                            <td id="menu_mainMenun8">
                                <table class="menu-staticitem menu_mainMenu_4" cellpadding="0" cellspacing="0" border="0"
                                    width="100%">
                                    <tr>
                                        <td style="white-space: nowrap;">
                                            <a class="menu_mainMenu_1 menu-staticitem menu_mainMenu_3" href="#" style="border-style: none;
                                                font-size: 1em; cursor: text;">
                                                <div>
                                                    Work</div>
                                            </a>
                                        </td>
                                    </tr>
                                </table>
                            </td>
                            <td style="width: 3px;">
                            </td>
                            <td id="menu_mainMenun9">
                                <table class="menu-staticitem menu_mainMenu_4" cellpadding="0" cellspacing="0" border="0"
                                    width="100%">
                                    <tr>
                                        <td style="white-space: nowrap;">
                                            <a class="menu_mainMenu_1 menu-staticitem menu_mainMenu_3" href="#" style="border-style: none;
                                                font-size: 1em; cursor: text;">
                                                <div>
                                                    Materials</div>
                                            </a>
                                        </td>
                                    </tr>
                                </table>
                            </td>
                            <td style="width: 3px;">
                            </td>
                            <td id="menu_mainMenun10">
                                <table class="menu-staticitem menu_mainMenu_4" cellpadding="0" cellspacing="0" border="0"
                                    width="100%">
                                    <tr>
                                        <td style="white-space: nowrap;">
                                            <a class="menu_mainMenu_1 menu-staticitem menu_mainMenu_3" href="#" style="border-style: none;
                                                font-size: 1em; cursor: text;">
                                                <div>
                                                    Procurement</div>
                                            </a>
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
        </table>
        <div class='search-name'>
            <span id="panel_labelCaption">Work</span>
        </div>
        <div class='search-buttons'>
            <table cellpadding="0" cellspacing="0" border="0" width="100%">
                <tr>
                    <td>
                        <table border='0' cellpadding='0' cellspacing='0'>
                            <tr>
                                <td>
                                    <span id="panel_spanSearch"><span id="panel_spanSearch_up"><span id="panel_spanSearch_sp">
                                        <div style="clear: both;">
                                            <span id="panel_buttonSearch">
                                                <img src="../../images/find.gif" align="absmiddle" style="border-width: 0px;" />&nbsp;<a
                                                    id="panel_buttonSearch_bt" href='javascript:void(0)'><asp:Label runat="server" ID="labelPerformSearch">Perform Search</asp:Label></a>&nbsp;
                                                &nbsp; </span>
                                        </div>
                                    </span></span></span>
                                </td>
                                <td>
                                    <span id="panel_buttonSearchNoFocus" style="display: none"><a id="panel_buttonSearchNoFocus_bt"
                                        href='javascript:void(0)' >
                                    </a>&nbsp; &nbsp; </span><span id="panel_buttonReset">
                                        <img src="../../images/symbol-refresh-big.gif" align="absmiddle" style="border-width: 0px;" />&nbsp;<a
                                            id="panel_buttonReset_bt" href='javascript:void(0)'>
                                            <asp:Label runat="server" ID="labelResetAllFields">Reset All Fields</asp:Label>
                                        </a>&nbsp; &nbsp; </span>
                                </td>
                                <td>
                                    <span id="panel_spanAddSelected"><span id="panel_spanAddSelected_up"></span></span>
                                </td>
                                <td>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
            </table>
        </div>
        <table class="tabstrip" width="100%" border="0" cellpadding="0" cellspacing="0">
            <tr>
                <td>
                    <ul>
                        <li id="uitabview3_li" style="display: inline;"><a href="#">
                            <asp:Label runat="server" ID="labelSearch">Search</asp:Label></a></li><li class="selected"
                                id="uitabview4_li" style="display: inline;"><a href="#">
                                    <asp:Label runat="server" ID="labelResults">Results</asp:Label></a></li>
                    </ul>
                </td>
            </tr>
        </table>
        <div class="div-form">
        <div id="gridResults" keyname="ObjectID" style="width: 100%; clear: both;">
            <table cellspacing="0" cellpadding="0" border="0" style="width: 100%; border-collapse: collapse;">
                <tr>
                    <td class="grid-caption" valign="top">
                        <div>
                            <span></span><span><asp:Label runat="server" ID="labelItems">1 item(s)</asp:Label></span>
                        </div>
                    </td>
                </tr>
            </table>
            <table cellspacing="0" cellpadding="0" border="0" style="width: 100%; border-collapse: collapse;">
                <tr>
                    <td class="grid-command">
                        <div>
                            <span>
                                <img src="../../images/delete.gif" align="absmiddle" style="border-width: 0px;" />&nbsp;<a
                                    id="gridResults_ctl11_bt" href='javascript:void(0)' >
                                    <asp:Label runat="server" ID="labelDeleteSelected">Delete Selected</asp:Label>
                                    </a>&nbsp; &nbsp; </span>
                        </div>
                    </td>
                </tr>
            </table>
            <div>
                <table cellspacing="0" border="0" id="gridResults_gridResults_gv" style="width: 100%;
                    border-collapse: collapse;">
                    <tr class="grid-header">
                        <th scope="col" style="width: 20px;">
                            <input id="gridResults_gridResults_gv_ctl01_checkMultiple" type="checkbox" name="gridResults$gridResults_gv$ctl01$checkMultiple"
                                onclick="selectCheckboxes(this);" />
                        </th>
                        <th align="left" scope="col" style="width: 16px;">
                            &nbsp;
                        </th>
                        <th align="left" scope="col" style="width: 16px;">
                            &nbsp;
                        </th>
                        <th align="left" scope="col" style="width: 16px;">
                            &nbsp;
                        </th>
                        <th align="left" scope="col">
                            <a href="javascript:void(0)">
                                <asp:Label runat="server" ID="labelHeaderWorkNumber">Work Number</asp:Label>
                                </a><img src="../../images/sort_descending.gif" align="absmiddle" style="border-width: 0px;" />
                        </th>
                        <th align="left" scope="col">
                            <a href="javascript:void(0)">
                                <asp:Label runat="server" ID="labelHeaderWorkDescription">Work Description</asp:Label>
                                </a>
                        </th>
                        <th align="left" scope="col">
                            <a href="javascript:void(0)">
                                <asp:Label runat="server" ID="labelHeaderTypeOfWork">Type of Work</asp:Label>
                                </a>
                        </th>
                        <th align="left" scope="col">
                            <a href="javascript:void(0)">
                                <asp:Label runat="server" ID="labelHeaderTypeOfService">Type of Service</asp:Label>
                                </a>
                        </th>
                        <th align="left" scope="col">
                            <a href="javascript:void(0)">
                                <asp:Label runat="server" ID="labelHeaderStatus">Status</asp:Label>
                                </a>
                        </th>
                    </tr>
                    <tr class="grid-row" style="background-color: White;">
                        <td style="width: 20px;">
                            <input id="gridResults_gridResults_gv_ctl02_checkMultiple" type="checkbox" name="gridResults$gridResults_gv$ctl02$checkMultiple" />
                        </td>
                        <td align="left">
                            <img src="../../images/edit.gif" 
                                style="border-width: 0px;" />
                        </td>
                        <td align="left">
                            <img src="../../images/view.gif" 
                                style="border-width: 0px;" />
                        </td>
                        <td align="left">
                            <img src="../../images/delete.gif" 
                                style="border-width: 0px;" />
                        </td>
                        <td align="left">
                            WO00000103
                        </td>
                        <td align="left">
                            <asp:Label runat="server" ID="labelWorkDescription1">Air-con too cold</asp:Label>
                        </td>
                        <td align="left">
                            <asp:Label runat="server" ID="labelTypeOfWork1">Corrective Maintenance</asp:Label>
                        </td>
                        <td align="left">
                            <asp:Label runat="server" ID="labelTypeOfService1">Air-Conditioning</asp:Label>
                        </td>
                        <td align="left">
                            <asp:Label runat="server" ID="labelStatus1">Pending Execution</asp:Label>
                        </td>
                    </tr>
                    <tr class="grid-pager">
                        <td colspan="9">
                            <div>
                                <table border="0">
                                    <tr>
                                        <td>
                                            <span>1</span>
                                        </td>
                                        <td>
                                            <a href="javascript:void(0)">2</a>
                                        </td>
                                        <td>
                                            <a href="javascript:void(0)">3</a>
                                        </td>
                                    </tr>
                                </table>
                            </div>
                        </td>
                    </tr>
                </table>
            </div>
            </div>
        </div>
    </form>
</body>
</html>
