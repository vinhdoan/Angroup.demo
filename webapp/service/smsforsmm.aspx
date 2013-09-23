<%@ Page Language="C#" %>
<%@ Import Namespace="Anacle.DataFramework" %>
<%@ Import Namespace="LogicLayer" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<script runat="server">
    
    /// <summary>
    /// jobno
    /// action
    /// </summary>
    /// <param name="e"></param>
    protected override void OnLoad(EventArgs e)
    {
        #region Special Condition - CHECK keyword
        if (Page.Request["k"] != null && Page.Request["phone"] != null && Page.Request["k"].ToUpper() == "CHK")
        {
            OMessage.SendSms(Page.Request["phone"], "SMS Server system check received. Message received on " + DateTime.Now.ToString());
            return;
        }
        #endregion
        
        string jobno = "";
        string phone = "";
        string action = "";
        if (!IsPostBack)
        {
            if (Page.Request["jobno"] == null || Page.Request["jobno"] == "")
            {
                OMessage.SendSms(phone, "[Parameter 'JobNo' unavailable]");
                return;
            }
            else jobno = Page.Request["jobno"].Trim();
            if (Page.Request["k"] == null || Page.Request["k"] == "")
            {
                OMessage.SendSms(phone, "[Parameter 'Action' unavailable]");
                return;
            }
            else action = Page.Request["k"];
            if (Page.Request["phone"] == null || Page.Request["phone"] == "")
            {
                OMessage.SendSms(phone, "[Parameter 'Phone' unavailable]");
                return;
            }
            else phone = Page.Request["phone"];

            OWork work = null;
            //Load object.
            try
            {
                work = TablesLogic.tWork[
                    TablesLogic.tWork.ObjectNumber == jobno][0];
                if (work == null) throw new Exception();
            }
            catch
            {
                OMessage.SendSms(phone, jobno + " is not a valid job number]");
                return;
            }

            switch (action.ToUpper())
            {
                case "ACE":
                case "ACM":
                case "ACN":
                case "ACB":
                case "ACS":
                    try
                    {
                        work.AcknowledgeWork();
                        OMessage.SendSms(phone, "Work " + jobno + " acknowledged successfully.");
                    }
                    catch (Exception ex)
                    {
                        if (ex.Message == "Work_ArrivedBeforeAck")
                            OMessage.SendSms(phone,
                                String.Format(Resources.Errors.Work_ArrivedBeforeAck, jobno));
                        else if (ex.Message == "Work_AlreadyAcknowledged")
                            OMessage.SendSms(phone,
                                String.Format(Resources.Errors.Work_AlreadyAcknowledged, jobno));
                        else
                        {
                            Response.Write("Unknown error during work acknowledgement: " + ex.Message);
                            OMessage.SendSms(phone, "Unknown error during work acknowledgement: ");
                        }
                    }
                    break;
                case "ARE":
                case "ARM":
                case "ARN":
                case "ARB":
                case "ARS":
                    try
                    {
                        work.ArriveWork();
                        OMessage.SendSms(phone, "Work " + jobno + " arrived successfully");
                    }
                    catch (Exception ex)
                    {
                        if (ex.Message == "Work_AlreadyArrived")
                            OMessage.SendSms(phone,
                                String.Format(Resources.Errors.Work_AlreadyArrived, jobno));
                        else OMessage.SendSms(phone, "Unknown error during work arrival.");
                    }
                    break;
                case "COE":
                case "COM":
                case "CON":
                case "COB":
                case "COS":
                    try
                    {
                        work.CompleteWork();
                        OMessage.SendSms(phone, "Work " + jobno + " completed successfully");
                    }
                    catch (Exception ex)
                    {
                        if (ex.Message == "Work_AlreadyCompleted")
                            OMessage.SendSms(phone,
                                String.Format(Resources.Errors.Work_AlreadyCompleted, jobno));
                        else OMessage.SendSms(phone, "Unknown error during work completion.");
                    }
                    break;
                default:
                    OMessage.SendSms(phone, action + " is not a valid action");
                    break;
            }
        }
    }
</script>

<html xmlns="http://www.w3.org/1999/xhtml" >
<head runat="server">
    <title>Untitled Page</title>
</head>
<body>
    <form id="form1" runat="server">
    <div>
    
    </div>
    </form>
</body>
</html>
