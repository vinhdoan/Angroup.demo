<%@ Page Language="C#" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<script runat="server">

    protected void buttontest_Click(object sender, EventArgs e)
    {
        string message = "";
        OWork w = TablesLogic.tWork.Create();
        
        DateTime now = DateTime.Now;
        for (int i = 0; i < 10; i++)
        {

            try
            {
                OWork work = TablesLogic.tWork.Create();
                using (Connection c = new Connection())
                {
                    work.LocationID = new Guid("91A6AAAF-99A5-44B5-8D0C-390D8420CC08");
                    work.Priority = 0;
                    work.WorkDescription = "Testing concurrency";
                    work.TypeOfWorkID = new Guid("13965CEE-3408-477E-AFDE-04B5EAF3C323");
                    work.TypeOfServiceID = new Guid("9E59F74C-C125-49E0-AB67-E7759D7F77A5");
                    work.TypeOfProblemID = new Guid("0F1D65D1-89AB-4CC0-B928-86E290CCC324");
                    work.ScheduledStartDateTime = new DateTime(2010, 09, 01);
                    work.ScheduledEndDateTime = new DateTime(2010, 09, 01);
                    work.ActualStartDateTime = new DateTime(2010, 09, 01);
                    work.ActualEndDateTime = new DateTime(2010, 09, 01);
                    work.ResolutionDescription = "";
                    work.Save();
                    message += (DateTime.Now.ToString("dd-MMM-yyyy hh:mm:ss") + ": " + work.ObjectNumber + " created" + "<br/>");
                    c.Commit();
                }

                using (Connection c = new Connection())
                {
                    work.TriggerWorkflowEvent("SaveAsDraft");
                    work.Save();
                    message += (DateTime.Now.ToString("dd-MMM-yyyy hh:mm:ss") + ": " + work.ObjectNumber + " saved as draft<br/>");
                    c.Commit();
                }

                using (Connection c = new Connection())
                {
                    work.TriggerWorkflowEvent("SubmitForAssignment");
                    work.Save();
                    message += (DateTime.Now.ToString("dd-MMM-yyyy hh:mm:ss") + ": " + work.ObjectNumber + " submitted for assignment<br/>");
                    c.Commit();
                }

                using (Connection c = new Connection())
                {
                    work.TriggerWorkflowEvent("SubmitForExecution");
                    work.Save();
                    message += (DateTime.Now.ToString("dd-MMM-yyyy hh:mm:ss") + ": " + work.ObjectNumber + " submitted for execution<br/>");
                    c.Commit();
                }

                using (Connection c = new Connection())
                {
                    work.TriggerWorkflowEvent("SubmitForClosure");
                    work.Save();
                    message += (DateTime.Now.ToString("dd-MMM-yyyy hh:mm:ss") + ": " + work.ObjectNumber + " submitted for closure<br/>");
                    c.Commit();
                }

                using (Connection c = new Connection())
                {
                    work.TriggerWorkflowEvent("Close");
                    work.Save();
                    message += (DateTime.Now.ToString("dd-MMM-yyyy hh:mm:ss") + ": " + work.ObjectNumber + " closed<br/>");
                    c.Commit();
                }

            }
            catch (Exception ex)
            {
                while (ex != null)
                {
                    message += (DateTime.Now.ToString("dd-MMM-yyyy hh:mm:ss") + ": " + "Exception encountered: " + ex.Message + "<br/>");
                    message += (ex.StackTrace + "<br/>");
                    ex = ex.InnerException;
                }
            }
            //System.Threading.Thread.Sleep(10);

            labelSpeed.Text = "Time taken: " + DateTime.Now.Subtract(now).TotalSeconds + "seconds <br/>";
        }
    }
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
    <div>
        <asp:Button runat="server" ID="buttontest" Text="Test" OnClick="buttontest_Click" />
        <asp:Label runat='server' ID="labelSpeed"></asp:Label>
    </div>
    </form>
</body>
</html>
