using System;
using System.Collections.Generic;
using System.Text;
using System.Configuration;
using System.Data;
using System.Data.Odbc;
using System.Data.Common;
using System.Data.OleDb;

namespace DataMigration.Infrastructure
{
    public class ExcelHelper
    {
        private static string connString;

        public static void SetConnString(string filePath)
        {
            //connString = "Driver={Microsoft Excel Driver (*.xls)};Readonly=False;" + String.Format("DriverId=790;Dbq={0};", filePath);
            connString = "Provider=Microsoft.Jet.OLEDB.4.0;Data Source=" + filePath + ";Extended Properties='Excel 8.0;HDR=Yes;IMEX=1;Notify=False'";
            //connString = "Provider=Microsoft.ACE.OLEDB.12.0;Data Source=" + filePath + ";Extended Properties='Excel 12.0;HDR=Yes;IMEX=1;Notify=False'";
            FilePath = filePath;
        }

        private static string _fileDir;
        public static string FilePath
        {
            get { return _fileDir; }
            set { _fileDir = value; }
        }

        
        private static DbConnection conn;

        private static void EnsureConnection()
        {
            if (conn == null )
            {
                conn = new OleDbConnection(connString);
            }

            if (conn.ConnectionString != connString)
            {
                CloseConnection();
                conn = new OleDbConnection(connString);
            }

            if (conn.State != ConnectionState.Open)
            {
                conn.Open();
            }

        }

        public static void CloseConnection()
        {
            if (conn != null)
            {
                if (conn.State != ConnectionState.Closed)
                {
                    conn.Close();
                    conn.Dispose();
                }
            }
        }

        public static DataTable GetTableData(string tableName)
        {
            try
            {
                EnsureConnection();

                string sql = String.Format("select * from [{0}]", tableName);

                OleDbDataAdapter ad = new OleDbDataAdapter(sql, (OleDbConnection)conn);
                
                DataSet ds = new DataSet();

                ad.Fill(ds);

                conn.Close();

                return ds.Tables[0];
            }
            catch(Exception ex)
            {
                return null;
            }
            //finally
            //{
            //    CloseConnection();
            //}
        }

        public static DataTable ExecQuery(string sql)
        {
            try
            {
                EnsureConnection();

                OleDbDataAdapter ad = new OleDbDataAdapter(sql, (OleDbConnection)conn);

                DataSet ds = new DataSet();

                ad.Fill(ds);

                conn.Close();

                return ds.Tables[0];
            }
            catch
            {
                return null;
            }
            //finally
            //{
            //    CloseConnection();
            //}

        }

        public static object ExecScalar(string sql)
        {
            try
            {
                EnsureConnection();

                DbCommand command = conn.CreateCommand();
                command.CommandText = sql;

                return command.ExecuteScalar();
            }
            catch
            {
                return null;
            }
            //finally
            //{
            //    CloseConnection();
            //}
        }

        public static DataTable GetSchema()
        {
            //try
            //{
                EnsureConnection();
                DataTable dt = conn.GetSchema(System.Data.OleDb.OleDbMetaDataCollectionNames.Tables);
                conn.Close();
                return dt;
            //}
            //catch
            //{
            //    return null;
            //}
            //finally
            //{
            //    CloseConnection();
            //}
        }

        public static bool UpdateRowStatus(string tablename,string message,string rownum)
        {
            string sql = String.Format("update [{0}] set errormessage = '{1}' where rowid={2}",tablename,message,rownum);
            return ExecNonQuery(sql);
        }

        public static bool AddNewColumn(string column,string tablename)
        {
            string sql = String.Format("alter table [{0}] add column [{1}] text(300)", tablename, column);
            return ExecNonQuery(sql);
        }

        private static bool ExecNonQuery(string sql)
        {
            try
            {
                EnsureConnection();
                DbCommand command = conn.CreateCommand();
                command.CommandText = sql;
                return command.ExecuteNonQuery() > 0;
            }
            catch
            {
                return false;
            }
            //finally
            //{
            //    CloseConnection();
            //}
        }

        public static DbDataReader ExecReader(string sql)
        {
            try
            {
                EnsureConnection();
                DbCommand command = conn.CreateCommand();
                command.CommandText = sql;
                command.CommandType = CommandType.Text;
                command.Connection = conn;
                DbDataReader reader = command.ExecuteReader();
                return reader;
            }
            catch
            {
                return null;
            }
        }
    }
}
