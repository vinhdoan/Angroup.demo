<%@ Page Language="C#" Inherits="PageBase" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.Common" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Transactions" %>

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
        /*
        DbCommand cmd = null;
        DbParameter p = null;

        TransactionOptions o = new TransactionOptions();
        o.IsolationLevel = System.Transactions.IsolationLevel.ReadCommitted;
        
        using (TransactionScope tx = new TransactionScope())
        {
            DbProviderFactory db = DbProviderFactories.GetFactory("System.Data.SqlClient");
            using (DbConnection c = db.CreateConnection())
            {
                c.ConnectionString = "server=abell\\sql2005; database=abell60_capitaland_test; uid=sa; pwd=hc0811";
                c.Open();

                try
                {
                    cmd = db.CreateCommand();
                    cmd.CommandTimeout = 3600;
                    cmd.CommandText = "SET @m = getdate(); UPDATE CodeType SET ModifiedDateTime=@m WHERE ObjectName = 'TenantActivityType'";
                    p = db.CreateParameter();
                    p.DbType = DbType.DateTime;
                    p.ParameterName = "m";
                    p.Direction = ParameterDirection.Output;
                    cmd.Parameters.Add(p);
                    cmd.Connection = c;
                    cmd.ExecuteNonQuery();

                    cmd = db.CreateCommand();
                    cmd.CommandTimeout = 3600;
                    cmd.CommandText = "INSERT INTO Message (ObjectID, Message) VALUES (newid(), 'T1a')";
                    cmd.Connection = c;
                    cmd.ExecuteNonQuery();

                    System.Threading.Thread.Sleep(3000);

                    cmd = db.CreateCommand();
                    cmd.CommandTimeout = 3600;
                    cmd.CommandText = "SET @m = getdate(); UPDATE Code SET ModifiedDateTime=@m WHERE ObjectID = 'CCC6CEDD-63B3-4DEF-8973-5A666753321A'";
                    p = db.CreateParameter();
                    p.DbType = DbType.DateTime;
                    p.ParameterName = "m";
                    p.Direction = ParameterDirection.Output;
                    cmd.Parameters.Add(p);
                    cmd.Connection = c;
                    cmd.ExecuteNonQuery();

                    cmd = db.CreateCommand();
                    cmd.CommandTimeout = 3600;
                    cmd.CommandText = "INSERT INTO Message (ObjectID, Message) VALUES (newid(), 'T1b')";
                    cmd.Connection = c;
                    cmd.ExecuteNonQuery();
                }
                catch (Exception ex)
                {
                    cmd = cmd;
                }
                c.Close();
            }
            tx.Complete();
        }*/

        using (Connection c = new Connection())
        {
            DbParameter p = Anacle.DataFramework.Parameter.DateTime("m", DBNull.Value);
            p.Direction = ParameterDirection.Output;
            Connection.ExecuteNonQuery("#database", "SET @m = getdate(); UPDATE CodeType SET ModifiedDateTime=@m WHERE ObjectName = 'TenantActivityType'", p);

            System.Threading.Thread.Sleep(3000);

            DbParameter p2 = Anacle.DataFramework.Parameter.DateTime("m", DBNull.Value);
            p2.Direction = ParameterDirection.Output;
            Connection.ExecuteNonQuery("#database", "SET @m = getdate(); UPDATE Code SET ModifiedDateTime=@m WHERE ObjectID = 'CCC6CEDD-63B3-4DEF-8973-5A666753321A'", p2);

            c.Commit();
        }
        t1complete = true;
    }

    protected void t2()
    {
        /*
        DbCommand cmd = null;
        DbParameter p = null;
        using (TransactionScope tx = new TransactionScope())
        {
            DbProviderFactory db = DbProviderFactories.GetFactory("System.Data.SqlClient");
            using (DbConnection c = db.CreateConnection())
            {
                try
                {
                    c.ConnectionString = "server=abell\\sql2005; database=abell60_capitaland_test; uid=sa; pwd=hc0811";
                    c.Open();

                    cmd = db.CreateCommand();
                    cmd.CommandTimeout = 3600;
                    cmd.CommandText = "SET @m = getdate(); UPDATE Code SET ModifiedDateTime=@m WHERE ObjectID = 'CCC6CEDD-63B3-4DEF-8973-5A666753321A'";
                    p = db.CreateParameter();
                    p.DbType = DbType.DateTime;
                    p.ParameterName = "m";
                    p.Direction = ParameterDirection.Output;
                    cmd.Parameters.Add(p);
                    cmd.Connection = c;
                    cmd.ExecuteNonQuery();

                    cmd = db.CreateCommand();
                    cmd.CommandTimeout = 3600;
                    cmd.CommandText = "INSERT INTO Message (ObjectID, Message) VALUES (newid(), 'T2a')";
                    cmd.Connection = c;
                    cmd.ExecuteNonQuery();

                    System.Threading.Thread.Sleep(3000);

                    cmd = db.CreateCommand();
                    cmd.CommandTimeout = 3600;
                    cmd.CommandText = "SET @m = getdate(); UPDATE CodeType SET ModifiedDateTime=@m WHERE ObjectName = 'TenantActivityType'";
                    p = db.CreateParameter();
                    p.DbType = DbType.DateTime;
                    p.ParameterName = "m";
                    p.Direction = ParameterDirection.Output;
                    cmd.Parameters.Add(p);
                    cmd.Connection = c;
                    cmd.ExecuteNonQuery();

                    cmd = db.CreateCommand();
                    cmd.CommandTimeout = 3600;
                    cmd.CommandText = "INSERT INTO Message (ObjectID, Message) VALUES (newid(), 'T2b')";
                    cmd.Connection = c;
                    cmd.ExecuteNonQuery();
                }
                catch (Exception ex)
                {
                    cmd = cmd;
                }

                c.Close();
            }
            tx.Complete();
        }*/
        using (Connection c = new Connection())
        {
            DbParameter p2 = Anacle.DataFramework.Parameter.DateTime("m", DBNull.Value);
            p2.Direction = ParameterDirection.Output;
            Connection.ExecuteNonQuery("#database", "SET @m = getdate(); UPDATE Code SET ModifiedDateTime=@m WHERE ObjectID = 'CCC6CEDD-63B3-4DEF-8973-5A666753321A'", p2);

            System.Threading.Thread.Sleep(3000);

            DbParameter p = Anacle.DataFramework.Parameter.DateTime("m", DBNull.Value);
            p.Direction = ParameterDirection.Output;
            Connection.ExecuteNonQuery("#database", "SET @m = getdate(); UPDATE CodeType SET ModifiedDateTime=@m WHERE ObjectName = 'TenantActivityType'", p);

            c.Commit();
        }
        
        t1complete = true;
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
            <asp:Button runat='server' ID="buttonTestDeadlock" Text="TestDeadlock with basic SqlConnections" OnClick="buttonTestDeadlock_Click" />
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
