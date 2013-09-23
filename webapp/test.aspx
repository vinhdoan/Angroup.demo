<%@ Page Language="C#" Inherits="PageBase" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<script runat="server">
    string message = "";
    
    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);

    }

    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
    }


    protected void x()
    {
        DateTime now = DateTime.Now;
        for (int i = 0; i < 1; i++)
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
                    work.Touch();
                    work.Save();
                    message += (DateTime.Now.ToString("dd-MMM-yyyy hh:mm:ss") + ": " + work.ObjectNumber + " saved as draft<br/>");
                    c.Commit();
                }

                using (Connection c = new Connection())
                {
                    //WindowsWorkflowEngine.ForceErrorWhilePersisting = true;
                    work.TriggerWorkflowEvent("SubmitForAssignment");
                    work.Touch();
                    work.Save();
                    message += (DateTime.Now.ToString("dd-MMM-yyyy hh:mm:ss") + ": " + work.ObjectNumber + " submitted for assignment<br/>");
                    c.Commit();
                }
                //WindowsWorkflowEngine.ForceErrorWhilePersisting = false;
/*
                using (Connection c = new Connection())
                {
                    work.TriggerWorkflowEvent("SubmitForExecution");
                    work.Touch();
                    work.Save();
                    message += (DateTime.Now.ToString("dd-MMM-yyyy hh:mm:ss") + ": " + work.ObjectNumber + " submitted for execution<br/>");
                    c.Commit();
                }

                using (Connection c = new Connection())
                {
                    work.TriggerWorkflowEvent("SubmitForClosure");
                    work.Touch();
                    work.Save();
                    message += (DateTime.Now.ToString("dd-MMM-yyyy hh:mm:ss") + ": " + work.ObjectNumber + " submitted for closure<br/>");
                    c.Commit();
                }

                using (Connection c = new Connection())
                {
                    work.TriggerWorkflowEvent("Close");
                    work.Touch();
                    work.Save();
                    message += (DateTime.Now.ToString("dd-MMM-yyyy hh:mm:ss") + ": " + work.ObjectNumber + " closed<br/>");
                    c.Commit();
                }
*/
            }
            catch (Exception ex)
            {
                //WindowsWorkflowEngine.ForceErrorWhilePersisting = false;
                while (ex != null)
                {
                    message += (DateTime.Now.ToString("dd-MMM-yyyy hh:mm:ss") + ": " + "Exception encountered: " + ex.Message + "<br/>");
                    message += (ex.StackTrace + "<br/>");
                    ex = ex.InnerException;
                }
            }
            //System.Threading.Thread.Sleep(10);

            Response.Write("Time taken: " + DateTime.Now.Subtract(now).TotalSeconds + "seconds <br/>");

            /*
            message += (DateTime.Now.ToString("dd-MMM-yyyy hh:mm:ss" + <));
             * */
        }
    }


    protected void buttonTestRegex_Click(object sender, EventArgs e)
    {
        Match m = Regex.Match(textBody.Text, textRegex.Text);
        labelResult.Text = "Approve: " + m.Groups["Approve"].ToString() + "<br/>" + 
            "Comment: "+ m.Groups["Comment"].ToString();
    }

    protected void buttonTestConcurrent_Click(object sender, EventArgs e)
    {
        x();
        Response.Write(message + "<br/><br/>");
        Response.Write("Completed.<br/>");
    }

    protected void buttonEncrypt_Click(object sender, EventArgs e)
    {
        textEncrypted.Text = Security.Encrypt(textSource.Text);
    }

    protected void buttonDecrypt_Click(object sender, EventArgs e)
    {
        textSource.Text = Security.Encrypt(textEncrypted.Text);
    }


    protected bool t1complete = false;
    protected bool t2complete = false;

    protected void t1()
    {
        try
        {
            using (Connection c = new Connection())
            {
                Audit.UserName = "T1a";
                OCodeType ct = TablesLogic.tCodeType.Load(TablesLogic.tCodeType.ObjectName == "TenantActivityType");
                ct.Touch();
                ct.Save();
                OMessage.SendSms("test", "T1a");

                System.Threading.Thread.Sleep(3000);

                Audit.UserName = "T1b";
                OCode cc = TablesLogic.tCode.Load(TablesLogic.tCode.ObjectID == new Guid("CCC6CEDD-63B3-4DEF-8973-5A666753321A"));
                cc.Touch();
                cc.Save();
                OMessage.SendSms("test", "T1b");

                c.Commit();
            }
            t1complete = true;
        }
        catch
        {
        }
    }

    protected void t2()
    {
        
        try
        {
            using (Connection c = new Connection())
            {
                Audit.UserName = "T2a";
                OCode cc = TablesLogic.tCode.Load(TablesLogic.tCode.ObjectID == new Guid("CCC6CEDD-63B3-4DEF-8973-5A666753321A"));
                cc.Touch();
                cc.Save();
                OMessage.SendSms("test", "T2a");

                System.Threading.Thread.Sleep(3000);

                Audit.UserName = "T2b";
                OCodeType ct = TablesLogic.tCodeType.Load(TablesLogic.tCodeType.ObjectName == "AmosMeterTypeGroup");
                ct.Touch();
                ct.Save();
                OMessage.SendSms("test", "T2b");

                c.Commit();
            }
            t2complete = true;
        }
        catch
        {
        }
    }

    protected void buttonTestDeadlock_Click(object sender, EventArgs e)
    {
        t1complete = false;
        t2complete = false;

        System.Threading.Thread tx1 = new System.Threading.Thread(t1);
        System.Threading.Thread tx2 = new System.Threading.Thread(t2);
        tx1.Start();
        System.Threading.Thread.Sleep(1000);
        tx2.Start();
        tx1.Join();
        tx2.Join();

        labelMessage.Text = "";
        if (t1complete)
            labelMessage.Text += "T1 Complete; ";
        if (t2complete)
            labelMessage.Text += "T2 Complete; ";
    }

    protected void buttonUploadAttachments_Click(object sender, EventArgs e)
    {
        DateTime t = DateTime.Now;
        Random r = new Random();
        for (int i = 0; i < 100; i++)
        {
            using (Connection c = new Connection())
            {
                OAttachment a = TablesLogic.tAttachment.Create();
                byte[] bytes= new byte[500000];
                for(int j=0; j<bytes.Length; j++)
                    bytes[j] = (byte)r.Next(255);
                a.FileBytes = bytes;
                a.Save();
                c.Commit();
            }
        }
        TimeSpan d = DateTime.Now.Subtract(t);
        labelResult.Text = d.TotalSeconds + " secs to complete";
    }
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
        <div class="div-main">
            <asp:textbox runat='server' ID="textBody" Width="100%" Text="wthat is this?" TextMode="MultiLine" Rows='10'></asp:textbox>
            <asp:textbox runat='server' ID="textRegex" Width="100%" Text="^[\s]*(?<Approve>[A|a|R|r])[\s]+(?<Comment>.*)[\s|\S|\w|\W|.]*"></asp:textbox>
            <br />
            <asp:Button runat='server' ID='buttonTestRegex' Text="TestRegex" OnClick="buttonTestRegex_Click" />
            <br />
            <br />
            <asp:Label runat='server' ID='labelResult'></asp:Label>
            <br />
            <br />
            <asp:Button runat='server' ID="buttonTestConcurrent" Text="TestConcurrent" OnClick="buttonTestConcurrent_Click" />
            <asp:Button runat='server' ID="buttonTestDeadlock" Text="TestDeadlock" OnClick="buttonTestDeadlock_Click" />
            <asp:Button runat='server' ID="buttonTestDeadlock2" Text="TestDeadlock with basic SqlConnections" OnClick="buttonTestDeadlock_Click" />
            <asp:Button runat='server' ID="buttonUploadAttachments" Text="Upload Attachments" OnClick="buttonUploadAttachments_Click" />
            <br />
            <br />
            <asp:Label runat="server" ID="labelMessage"></asp:Label>
            <br />
            <hr />
            Source Text:
            <asp:textbox runat='server' ID="textSource" Width="100%" Text="" ></asp:textbox>
            Encrypted Text:
            <asp:textbox runat='server' ID="textEncrypted" Width="100%" Text="" ></asp:textbox>
            <asp:Button runat='server' ID='buttonEncrypt' Text="Encrypt" OnClick="buttonEncrypt_Click" />
            <asp:Button runat='server' ID='buttonDecrypt' Text="Decrypt" OnClick="buttonDecrypt_Click" />
        </div>
    </form>
</body>
</html>
