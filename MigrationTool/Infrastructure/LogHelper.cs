using System;
using System.Collections.Generic;
using System.Text;
using System.IO;
using System.Data;
namespace DataMigration.Infrastructure
{
    public class LogHelper
    {
        public static void LogDataImport(string mapFrom, DataTable table,ICollection<string> mappingCols)
        {
            StreamWriter logFileStreamWriter = null;
            try
            {
                if(!CheckIsNeedLog(table))return;
                mapFrom = mapFrom.Replace("$", "");
                string file = Path.GetFileNameWithoutExtension(ExcelHelper.FilePath);
                string path = Path.GetDirectoryName(ExcelHelper.FilePath)+"\\"+file+"_"+ mapFrom +"_error.csv";
                FileStream fs = new FileStream(path, FileMode.OpenOrCreate);
                logFileStreamWriter = new StreamWriter(fs,Encoding.Unicode);
                string csvColHeader = null;
                foreach (DataColumn  col in table.Columns)
                {
                    if (!mappingCols.Contains(col.ColumnName) &col.ColumnName!=Logic.Migratable.ERROR_MSG_COL) continue;
                    if (null != csvColHeader) csvColHeader += "\t";
                    csvColHeader += ConvertStringToCSV(col.ColumnName);
                }

                logFileStreamWriter.WriteLine(csvColHeader);
                //StringBuilder sb = new StringBuilder();
                //sb.AppendLine(csvColHeader);
                foreach (DataRow row in table.Rows)
                {
                    string rowString = null;
                    foreach (DataColumn col in table.Columns)
                    {
                        if (!mappingCols.Contains(col.ColumnName) & col.ColumnName != Logic.Migratable.ERROR_MSG_COL) continue;
                        if (null != rowString) rowString += "\t";
                        rowString += ConvertStringToCSV(row[col.ColumnName]);
                    }
                    //sb.AppendLine(rowString);
                    logFileStreamWriter.WriteLine(rowString);
                }
                //File.AppendAllText(path, sb.ToString());
                logFileStreamWriter.Flush();
            }
            finally
            {
                if (null != logFileStreamWriter)
                {
                    logFileStreamWriter.Flush();
                    logFileStreamWriter.Close();
                    logFileStreamWriter.Dispose();
                    logFileStreamWriter = null;
                }
            }

        }

        protected static bool CheckIsNeedLog(DataTable table)
        {
            foreach (DataRow var in table.Rows)
            {
                string error = ConvertStringToCSV(var[Logic.Migratable.ERROR_MSG_COL]);
                if (error != null & error != String.Empty) return true;
            }
            return false;
        }
        protected static string ConvertStringToCSV(object obj)
        {
            string source = null;
            if (null == obj) return null;
            if (DBNull.Value == obj) return null;
            source = Convert.ToString(obj);
            if (source == null || source == String.Empty) return null;
            source = source.Trim();

            string destination = null;
            //check char ,
            int index1 = source.IndexOf(',');
            //check \n
            int index2 = source.IndexOf("\n");
            //check \"
            int index3 = source.IndexOf("\"");
            source = source.Replace("\"", "\"\"");
            if (index1 >-1||index2>-1||index3>-1)
            {
                destination = "\"" + source + "\"";
            }
            else
            {
                destination = source;
            }
            return destination;
        }
    }
}
