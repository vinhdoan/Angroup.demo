using Anacle.DataFramework;
using LogicLayer;

using System;
using System.Collections;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Text;
using System.Windows.Forms;

using Anacle.WorkflowFramework;
using DataMigration.Infrastructure;
using DataMigration.Logic;
using System.Data.Common;

namespace DataMigration
{
    public partial class MainForm : Form
    {
        //System.Data.Odbc.OdbcConnection conn;

        public MainForm()
        {
            InitializeComponent();

            // Initialize the DataFramework
            //
            Anacle.DataFramework.Global.Initialize();

            // Initializes the workflow engine.
            //
            WorkflowEngine.Initialize();
            WorkflowEngine.Engine.StartWorkflowEngine();

        }

        private void buttonBrowseData_Click(object sender, EventArgs e)
        {
            try
            {
                //openFileDialog1.ShowDialog();
                //string connString = "Driver={Microsoft Excel Driver (*.xls)};" + String.Format("DriverId=790;Dbq={0};", openFileDialog1.FileName);
                
                if (openFileDialog1.ShowDialog() == DialogResult.Cancel)
                    return;

                DataTable dt = null;

                if (openFileDialog1.FileName.EndsWith(".csv") || openFileDialog1.FileName.EndsWith(".CSV"))
                {
                    dt = Data.Import(openFileDialog1.FileName, ',');
                    PopulateTable(dt);
                    listBox_MigrateFrom.Items.Clear();
                    listBox_MigrateFrom.Enabled = false;
                }
                else
                {
                    openFileDialog1.OpenFile();
                    ExcelHelper.SetConnString(openFileDialog1.FileName);
                    dt = ExcelHelper.GetSchema();
                    dataGridView1.DataSource = null;
                    listBox_MigrateFrom.Enabled = true;
                    listBox_MigrateFrom.Items.Clear();
                    if (dt != null)
                        foreach (DataRow row in dt.Rows)
                            listBox_MigrateFrom.Items.Add(row[2]);
                    else
                        MessageBox.Show("Cannot get excel file");
                }

                buttonMigrate.Enabled = ((listBox_MigrateTo.SelectedValue != null && listBox_MigrateFrom.SelectedItem != null) || (listBox_MigrateTo.SelectedValue != null && listBox_MigrateFrom.SelectedItem == null && (openFileDialog1.FileName.EndsWith(".csv") || openFileDialog1.FileName.EndsWith(".CSV"))));
                buttonMapColumns.Enabled = ((listBox_MigrateTo.SelectedValue != null && listBox_MigrateFrom.SelectedItem != null) || (listBox_MigrateTo.SelectedValue != null && listBox_MigrateFrom.SelectedItem == null && (openFileDialog1.FileName.EndsWith(".csv") || openFileDialog1.FileName.EndsWith(".CSV"))));
            }
            catch (Exception ex)
            {
                //MessageBox.Show(ex.Message);
                MessageBox.Show(ex.StackTrace);
                
            }
           
        }

        private void buttonBrowseXML_Click(object sender, EventArgs e)
        {
            try
            {
                //openFileDialog2.ShowDialog();
                if (openFileDialog2.ShowDialog() == DialogResult.Cancel)
                    return;
                
                openFileDialog2.OpenFile();

                Configuration.SetXMLFile(openFileDialog2.FileName);
                listBox_MigrateTo.DataSource = null;
                listBox_MigrateTo.Items.Clear();
                listBox_MigrateTo.DataSource = Infrastructure.Configuration.AllMigrations;

                buttonMigrate.Enabled = ((listBox_MigrateTo.SelectedValue != null && listBox_MigrateFrom.SelectedItem != null) || (listBox_MigrateTo.SelectedValue != null && listBox_MigrateFrom.SelectedItem == null && (openFileDialog1.FileName.EndsWith(".csv") || openFileDialog1.FileName.EndsWith(".CSV"))));
                buttonMapColumns.Enabled = ((listBox_MigrateTo.SelectedValue != null && listBox_MigrateFrom.SelectedItem != null) || (listBox_MigrateTo.SelectedValue != null && listBox_MigrateFrom.SelectedItem == null && (openFileDialog1.FileName.EndsWith(".csv") || openFileDialog1.FileName.EndsWith(".CSV"))));
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
            }

        }
        private void PopulateTable(DataTable dt)
        {
            try
            {
              
                dataGridView1.DataSource = dt;
                dataGridView1.AllowUserToAddRows = false;
                dataGridView1.AllowUserToDeleteRows = false;

                mapFromCols.Clear();
                if (null == dt) return;
                foreach (DataColumn var in dt.Columns)
                {
                    mapFromCols.Add(var.ColumnName);
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
            }
        }
        //XML listbox
        private void listBox1_SelectedIndexChanged(object sender, EventArgs e)
        {
            string mapFrom = listBox_MigrateFrom.SelectedItem.ToString();
            DataTable dt = ExcelHelper.GetTableData(mapFrom);
            PopulateTable(dt);
            buttonMigrate.Enabled = ((listBox_MigrateTo.SelectedValue != null && listBox_MigrateFrom.SelectedItem != null) || (listBox_MigrateTo.SelectedValue != null && listBox_MigrateFrom.SelectedItem == null && (openFileDialog1.FileName.EndsWith(".csv") || openFileDialog1.FileName.EndsWith(".CSV"))));
            buttonMapColumns.Enabled = ((listBox_MigrateTo.SelectedValue != null && listBox_MigrateFrom.SelectedItem != null) || (listBox_MigrateTo.SelectedValue != null && listBox_MigrateFrom.SelectedItem == null && (openFileDialog1.FileName.EndsWith(".csv") || openFileDialog1.FileName.EndsWith(".CSV"))));

        }

        private List<string> mapFromCols = new List<string>();
        private Dictionary<string, Dictionary<string, string>> _mapSettingDict = new Dictionary<string, Dictionary<string, string>>();
       
        private void buttonMapColumns_Click(object sender, EventArgs e)
        {
            try
            {
                //string strmapfrom = listBox_MigrateFrom.SelectedItem.ToString();
                Dictionary<string, string> currentMap = null;
                string migrateTo = listBox_MigrateTo.SelectedValue.ToString();
                if (_mapSettingDict.ContainsKey(migrateTo))
                {
                    currentMap = _mapSettingDict[migrateTo];
                }
                List<string> mapToCols = Configuration.GetMigrateConfig(migrateTo).Fields;
                List<string> dataType = Configuration.GetMigrateConfig(migrateTo).FieldType;

                Map map = new Map(mapToCols, mapFromCols, dataType);
                if (currentMap != null)
                    map.MapList = currentMap;
                                

                if (map.ShowDialog() == DialogResult.OK)
                {
                    currentMap = null;
                    currentMap = map.MapList;
                    if (!_mapSettingDict.ContainsKey(migrateTo))
                    {
                        _mapSettingDict.Add(migrateTo, currentMap);
                    }
                    else
                    {
                        _mapSettingDict[migrateTo] = currentMap;
                    }
                    buttonMigrate.Enabled = true;
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
            }

          
        }

        private void buttonMigrate_Click(object sender, EventArgs e)
        {
            try
            {
                //MessageBox.Show("Please wait,migrate start...");
                this.Cursor = Cursors.WaitCursor;
                // Get the type of data to migrate.
                string[] stringSeparators = new string[] { "\\" };
                string[] filename = openFileDialog1.FileName.Split(stringSeparators,StringSplitOptions.RemoveEmptyEntries);

                string mapfrom = "'" + filename[filename.Length - 1].Remove(filename[filename.Length - 1].Length - 4) + "$'";
                if(listBox_MigrateFrom.SelectedItem != null)
                    mapfrom = listBox_MigrateFrom.SelectedItem.ToString();
                string mapto = listBox_MigrateTo.SelectedValue.ToString();

                // Check column mapping.
                if (_mapSettingDict[mapto] == null || _mapSettingDict[mapto].Count == 0)
                {
                    MessageBox.Show("Please map column!");
                    return;
                }

                Migratable handler = Factory.Create(mapfrom, mapto, openFileDialog1.FileName);
                handler.Map = _mapSettingDict[mapto];
                // Get the spreadsheet to migrate from.
                handler.Migarate();
                MessageBox.Show("Migarate finished!");
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
            }
            finally 
            {
                this.Cursor = Cursors.Arrow;
            }

        }

        protected override void OnClosed(EventArgs e)
        {
            base.OnClosed(e);
            ExcelHelper.CloseConnection();
        }

        private void MainForm_Load(object sender, EventArgs e)
        {
            //listBox_MigrateTo.DataSource = Infrastructure.Configuration.AllMigrations;
            buttonMigrate.Enabled = false;
            buttonMapColumns.Enabled = false;
            //Anacle.DataFramework.Agreement.GlobalLicenseString = System.Configuration.ConfigurationManager.AppSettings["LicenseKey"];
        }

        private void listBox_MigrateTo_SelectedIndexChanged(object sender, EventArgs e)
        {
            buttonMigrate.Enabled = ((listBox_MigrateTo.SelectedValue != null && listBox_MigrateFrom.SelectedItem != null) || (listBox_MigrateTo.SelectedValue != null && listBox_MigrateFrom.SelectedItem == null && (openFileDialog1.FileName.EndsWith(".csv") || openFileDialog1.FileName.EndsWith(".CSV"))));
            buttonMapColumns.Enabled = ((listBox_MigrateTo.SelectedValue != null && listBox_MigrateFrom.SelectedItem != null) || (listBox_MigrateTo.SelectedValue != null && listBox_MigrateFrom.SelectedItem == null && (openFileDialog1.FileName.EndsWith(".csv") || openFileDialog1.FileName.EndsWith(".CSV"))));
        }


    }

    public class MigrationTypes
    {

        //public static string[] types = new string[1] { "Type Of Service" };
               
        public enum TypeOfService_Columns
        {
            TypeOfWork,
            TypeOfService,
            TypeOfProblem,
            CauseOfProblem,
            Resolution
        }
    }
}