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
        String phoneNum = "";
        if (Page.Request["phone"] != null)
        {
            if (Page.Request["phone"].Trim().Substring(0, 2) == "65")
            {
                phoneNum = (Page.Request["phone"]).Trim().Substring(2, Page.Request["phone"].Trim().Length - 2);
            }
            else
                phoneNum = Page.Request["phone"].Trim();
        }
        
        if (Page.Request["k"] != null && phoneNum != null && Page.Request["k"].ToUpper() == "CHK")
        {
            OMessage.SendSms(phoneNum, "SMS Server system check received. Message received on " + DateTime.Now.ToString());
            Response.End();
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
                Response.End();
                return;
            }
            else 
                jobno = Page.Request["jobno"].Trim();
            if (Page.Request["k"] == null || Page.Request["k"] == "")
            {
                OMessage.SendSms(phone, "[Parameter 'Action' unavailable]");
                Response.End();
                return;
            }
            else action = Page.Request["k"];
            if (phoneNum == null || phoneNum == "")
            {
                OMessage.SendSms(phone, "[Parameter 'Phone' unavailable]");
                Response.End();
                return;
            }
            else 
                phone = phoneNum;

            OWork work = null;
            
            //Load object.
            try
            {
                /* 2011.09.22, Kien Trung
                 * Temporarily commented out since the work order number format has been changed.
                 * Therefore, we have to match exact WO number instead.
                 * 
                ORunningNumberGenerator runningNum = TablesLogic.tRunningNumberGenerator.Load(
                    TablesLogic.tRunningNumberGenerator.ObjectTypeName == "OWork");
                
                string[] separator = new string[]{"-"};
                string[] tempList = jobno.Split(separator, StringSplitOptions.RemoveEmptyEntries);

                if (tempList.Length != 2) throw new Exception();
                else
                {
                    String tempNum = FormatRunningNum(tempList[1], runningNum.FormatString);
                    jobno = tempList[0] + "-" + runningNum.ObjectTypeCode + tempNum;
                }
                */
                
                work = TablesLogic.tWork[
                    TablesLogic.tWork.ObjectNumber == jobno][0];
                if (work == null) throw new Exception();
            }
            catch
            {
                OMessage.SendSms(phone, jobno + " is not a valid job number]");
                Response.End();
                return;
            }

            switch (action.ToUpper())
            {
                case "ACK":
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
                        Response.End();
                    }
                    break;
                case "ARR":
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
                        Response.End();
                    }
                    break;
                case "COM":
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
                        Response.End();
                    }
                    break;
                default:
                    OMessage.SendSms(phone, action + " is not a valid action");
                    break;
            }
        }
        Response.End();
    }
    
    /// <summary>
    /// 
    /// </summary>
    /// <param name="tempNum"></param>
    /// <param name="format"></param>
    /// <returns></returns>
    public String FormatRunningNum(String tempNum, String format)
    {
        string[] separator = new string[]{"-",":","{","}","/"};
        string[] tempList = format.Split(separator, StringSplitOptions.RemoveEmptyEntries);
        int count = tempList[tempList.Length-1].ToString().Length;
        count = count - tempNum.Length;
        for(int i=0; i<count; i++)
        {
            tempNum = "0" + tempNum;
        }
        return tempNum;
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
