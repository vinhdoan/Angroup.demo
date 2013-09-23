using System;
using System.Collections;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Text;
using System.Windows.Forms;

namespace DataMigration
{
    public partial class Map : Form
    {
        public Map(List<string> mapToCols, List<string> matFromCols, List<string> dataType)
        {
            _mapToCols = mapToCols;
            _matFromCols = matFromCols;
            _dataType = dataType;
            InitializeComponent();

        }

        private List<string> _mapToCols;
        private List<string> _matFromCols;
        private List<string> _dataType;

        private DataTable _gridData;
        public Dictionary<string, string> MapList
        {
            get 
            {
                Dictionary<string, string> list = new Dictionary<string, string>();
                foreach (DataRow var in _gridData.Rows)
                {
                        string des = Convert.ToString(var["Destination"]);
                        
                        string sou = null;
                        if (var["Source"] != DBNull.Value)
                        {
                            sou = Convert.ToString(var["Source"]);
                        }
                        list.Add(des, sou);
                }
                return list;
            }
            set 
            {
                if (null != value)
                    InitGridData(value);
            }
        }

        private void InitGridData(Dictionary<string, string> source)
        {
            try
            {
                _gridData = new DataTable();
                DataColumn dc1 = _gridData.Columns.Add("Destination", typeof(string));
                DataColumn dc2 = _gridData.Columns.Add("Source", typeof(string));
                DataColumn dc3 = _gridData.Columns.Add("DataType", typeof(string));
                //dc2.Unique = true;
                if (null == source)
                {
                    int count1 = 0;
                    foreach (string var in _mapToCols)
                    {    
                        DataRow dr = _gridData.NewRow();
                        dr[0] = var;
                        dr[1] = null;
                        foreach (string s in _matFromCols)
                        {
                            if (s == var)
                            {
                                dr[1] = var;
                                break;
                            }
                        }
                        dr[2] = _dataType[count1];
                        _gridData.Rows.Add(dr);
                        count1++;
                    }
                }
                else
                {
                    int count2 = 0;

                    foreach (string var in source.Keys)
                    {
                        DataRow dr = _gridData.NewRow();
                        dr[0] = var;
                        dr[1] = source.ContainsKey(var) ? source[var] : null;
                        dr[2] = _dataType[count2];
                        _gridData.Rows.Add(dr);
                        count2++;
                    }
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
            }

        }
        private void Map_Load(object sender, EventArgs e)
        {
            if (_gridData == null)
            {
                InitGridData(null);
            }
            this.Column1.DataPropertyName = "Destination";
            this.Column2.DataPropertyName = "Source";
            this.Column3.DataPropertyName = "DataType";

            this.Column2.Items.Add("");

            foreach (string obj in _matFromCols)
            {
                this.Column2.Items.Add(obj);
            }

            dataGridView1.DataSource = _gridData;
            dataGridView1.AllowUserToAddRows = false;
            dataGridView1.AllowUserToDeleteRows = false;
         }

        private void button1_Click(object sender, EventArgs e)
        {
            Dictionary<string, string> list = new Dictionary<string, string>();
            foreach (DataRow var in _gridData.Rows)
            {
                string des = Convert.ToString(var["Destination"]);
                string sou = null;
                if (var["Source"] != DBNull.Value && Convert.ToString(var["Source"]) != "")
                {
                    sou = Convert.ToString(var["Source"]);
                }
                //if (sou!=null&list.ContainsValue(sou))
                //{
                //    MessageBox.Show("Map from column '" + sou + "' dupplicated!Please change column mapping.");
                //    this.DialogResult = DialogResult.None;
                //    return;

                //}
                list.Add(des, sou);
            }
            DialogResult = DialogResult.OK;

        }
    }
   
}