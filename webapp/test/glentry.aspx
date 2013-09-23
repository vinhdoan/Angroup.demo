<%@ Page Language="C#" Inherits="PageBase" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<script runat="server">
    
    protected void CreateRandomGLButtons_Click(object sender, EventArgs e)
    {
        
        if (MonthYear.DateTime != null)
        {
            Random r = new Random();
            List<OGLAccount> glAccounts = TablesLogic.tGLAccount.LoadAll();

            DateTime start = DateTime.Now;
            int documentNumber = 0;
            for (int day = 1; day <= 100; day++)
            {
                for (int i = 0; i < 20000; i++)
                {
                    using (Connection c = new Connection())
                    {
                        OGLAccountEntry g1 = TablesLogic.tGLAccountEntry.Create();
                        OGLAccountEntry g2 = TablesLogic.tGLAccountEntry.Create();
                        g1.OriginatingDocumentID = new Guid();
                        g1.OriginatingDocumentNumber = documentNumber.ToString("0000000");
                        g1.OriginatingDocumentDate = new DateTime(
                            MonthYear.DateTime.Value.Year, MonthYear.DateTime.Value.Month, day).AddDays(day);
                        if (r.Next(20) == 1)
                            g1.OriginatingDocumentDate = g1.OriginatingDocumentDate.Value;
                        if (g1.OriginatingDocumentDate < new DateTime(2011, 04, 01))
                            g1.OriginatingDocumentDate = new DateTime(2011, 04, 01);
                            
                        g1.OriginatingObjectTypeName = "TEST";
                        g1.Description = "TEST";

                        g2.OriginatingDocumentID = new Guid();
                        g2.OriginatingDocumentNumber = documentNumber.ToString("0000000");
                        g2.OriginatingDocumentDate = g1.OriginatingDocumentDate;
                        g2.OriginatingObjectTypeName = "TEST";
                        g2.Description = "TEST";

                        g1.GLAccountID = glAccounts[r.Next(glAccounts.Count)].ObjectID;
                        g2.GLAccountID = glAccounts[r.Next(glAccounts.Count)].ObjectID;
                        //g1.GLAccountID = glAccounts[0].ObjectID;
                        //g2.GLAccountID = glAccounts[0].ObjectID;

                        if (r.Next(2) == 0)
                        {
                            g1.CreditAmount = r.Next(100) * 10;
                            g2.DebitAmount = g1.CreditAmount;
                        }
                        else
                        {
                            g1.DebitAmount = r.Next(100) * 10;
                            g2.CreditAmount = g1.DebitAmount;
                        }

                        List<OGLAccountEntry> entries = new List<OGLAccountEntry>();
                        entries.Add(g1);
                        entries.Add(g2);
                        OGLAccountEntry.PostGLAccountingEntries(entries);
                        c.Commit();
                    }
                }
            }

            LabelMessage.Text = "Completed. Took " + DateTime.Now.Subtract(start).TotalMinutes + " minutes";
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
        <ui:UIPanel runat='server' ID="Panel">
            <ui:UIFieldDateTime runat="server" ID="MonthYear" Caption="Month/Year" SelectMonthYear="true" />
            <ui:UIButton runat="server" ID="CreateRandomGLButtons" Text="Create Random General Ledger Entries" OnClick="CreateRandomGLButtons_Click" />
            <asp:label runat="server" ID="LabelMessage"></asp:label>
        </ui:UIPanel>
    </div>
    </form>
</body>
</html>
