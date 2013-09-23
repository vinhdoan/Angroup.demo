namespace DataMigration
{
    partial class MainForm
    {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            this.openFileDialog1 = new System.Windows.Forms.OpenFileDialog();
            this.openFileDialog2 = new System.Windows.Forms.OpenFileDialog();
            this.buttonBrowseData = new System.Windows.Forms.Button();
            this.listBox_MigrateFrom = new System.Windows.Forms.ListBox();
            this.dataGridView1 = new System.Windows.Forms.DataGridView();
            this.listBox_MigrateTo = new System.Windows.Forms.ListBox();
            this.label1 = new System.Windows.Forms.Label();
            this.label2 = new System.Windows.Forms.Label();
            this.buttonMigrate = new System.Windows.Forms.Button();
            this.buttonMapColumns = new System.Windows.Forms.Button();
            this.buttonBrowseXML = new System.Windows.Forms.Button();
            ((System.ComponentModel.ISupportInitialize)(this.dataGridView1)).BeginInit();
            this.SuspendLayout();
            // 
            // openFileDialog1
            // 
            //this.openFileDialog1.Filter = "Excel|*.xls|CSV|*.csv";
            this.openFileDialog1.Filter = "Excel, CSV|*.xls; *.xlsx; *.csv";
            // 
            // openFileDialog2
            // 
            this.openFileDialog2.Filter = "XML|*.xml";
            // 
            // buttonBrowseData
            // 
            this.buttonBrowseData.Location = new System.Drawing.Point(12, 20);
            this.buttonBrowseData.Name = "buttonBrowseData";
            this.buttonBrowseData.Size = new System.Drawing.Size(242, 23);
            this.buttonBrowseData.TabIndex = 1;
            this.buttonBrowseData.Text = "Browse Data File";
            this.buttonBrowseData.UseVisualStyleBackColor = true;
            this.buttonBrowseData.Click += new System.EventHandler(this.buttonBrowseData_Click);
            // 
            // listBox_MigrateFrom
            // 
            this.listBox_MigrateFrom.FormattingEnabled = true;
            this.listBox_MigrateFrom.Location = new System.Drawing.Point(12, 73);
            this.listBox_MigrateFrom.Name = "listBox_MigrateFrom";
            this.listBox_MigrateFrom.Size = new System.Drawing.Size(241, 108);
            this.listBox_MigrateFrom.TabIndex = 2;
            this.listBox_MigrateFrom.SelectedIndexChanged += new System.EventHandler(this.listBox1_SelectedIndexChanged);
            // 
            // dataGridView1
            // 
            this.dataGridView1.ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.AutoSize;
            this.dataGridView1.Location = new System.Drawing.Point(12, 201);
            this.dataGridView1.Name = "dataGridView1";
            this.dataGridView1.Size = new System.Drawing.Size(492, 150);
            this.dataGridView1.TabIndex = 3;
            // 
            // listBox_MigrateTo
            // 
            this.listBox_MigrateTo.FormattingEnabled = true;
            this.listBox_MigrateTo.Location = new System.Drawing.Point(259, 73);
            this.listBox_MigrateTo.Name = "listBox_MigrateTo";
            this.listBox_MigrateTo.Size = new System.Drawing.Size(245, 108);
            this.listBox_MigrateTo.TabIndex = 4;
            this.listBox_MigrateTo.SelectedIndexChanged += new System.EventHandler(this.listBox_MigrateTo_SelectedIndexChanged);
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Location = new System.Drawing.Point(12, 185);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(120, 13);
            this.label1.TabIndex = 5;
            this.label1.Text = "Data in the spreadsheet";
            // 
            // label2
            // 
            this.label2.AutoSize = true;
            this.label2.Location = new System.Drawing.Point(260, 54);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(83, 13);
            this.label2.TabIndex = 6;
            this.label2.Text = "Migrate data as:";
            // 
            // buttonMigrate
            // 
            this.buttonMigrate.Location = new System.Drawing.Point(510, 301);
            this.buttonMigrate.Name = "buttonMigrate";
            this.buttonMigrate.Size = new System.Drawing.Size(116, 50);
            this.buttonMigrate.TabIndex = 7;
            this.buttonMigrate.Text = "Migrate data from this spreadsheet";
            this.buttonMigrate.UseVisualStyleBackColor = true;
            this.buttonMigrate.Click += new System.EventHandler(this.buttonMigrate_Click);
            // 
            // buttonMapColumns
            // 
            this.buttonMapColumns.Location = new System.Drawing.Point(510, 201);
            this.buttonMapColumns.Name = "buttonMapColumns";
            this.buttonMapColumns.Size = new System.Drawing.Size(115, 23);
            this.buttonMapColumns.TabIndex = 8;
            this.buttonMapColumns.Text = "Map Columns";
            this.buttonMapColumns.UseVisualStyleBackColor = true;
            this.buttonMapColumns.Click += new System.EventHandler(this.buttonMapColumns_Click);
            // 
            // buttonBrowseXML
            // 
            this.buttonBrowseXML.Location = new System.Drawing.Point(259, 20);
            this.buttonBrowseXML.Name = "buttonBrowseXML";
            this.buttonBrowseXML.Size = new System.Drawing.Size(245, 23);
            this.buttonBrowseXML.TabIndex = 9;
            this.buttonBrowseXML.Text = "Browse XML File";
            this.buttonBrowseXML.UseVisualStyleBackColor = true;
            this.buttonBrowseXML.Click += new System.EventHandler(this.buttonBrowseXML_Click);
            // 
            // MainForm
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(639, 370);
            this.Controls.Add(this.buttonBrowseXML);
            this.Controls.Add(this.buttonMapColumns);
            this.Controls.Add(this.buttonMigrate);
            this.Controls.Add(this.label2);
            this.Controls.Add(this.label1);
            this.Controls.Add(this.listBox_MigrateTo);
            this.Controls.Add(this.dataGridView1);
            this.Controls.Add(this.listBox_MigrateFrom);
            this.Controls.Add(this.buttonBrowseData);
            this.Name = "MainForm";
            this.Text = "Data Migrator - Anacle Systems Pte Ltd";
            this.Load += new System.EventHandler(this.MainForm_Load);
            ((System.ComponentModel.ISupportInitialize)(this.dataGridView1)).EndInit();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.OpenFileDialog openFileDialog1;
        private System.Windows.Forms.OpenFileDialog openFileDialog2;
        private System.Windows.Forms.Button buttonBrowseData;
        private System.Windows.Forms.ListBox listBox_MigrateFrom;
        private System.Windows.Forms.DataGridView dataGridView1;
        private System.Windows.Forms.ListBox listBox_MigrateTo;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.Label label2;
        private System.Windows.Forms.Button buttonMigrate;
        private System.Windows.Forms.Button buttonMapColumns;
        private System.Windows.Forms.Button buttonBrowseXML;
    }
}

