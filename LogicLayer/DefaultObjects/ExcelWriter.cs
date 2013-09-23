using System;
using System.Collections.Generic;
using System.Text;
using System.Data;
using System.IO;
using System.Drawing;

using ExcelLibrary.SpreadSheet;
using Anacle.DataFramework;

namespace LogicLayer
{
    public class ExcelWriter
    {
        /// <summary>
        /// Generates excel file from input data table.
        /// Format header background to red or yellow to indicate compulsory columns or  non-compulsory columns respectively.
        /// </summary>
        /// <param name="table"></param>
        /// <param name="filePath"></param>
        /// <param name="workSheetName"></param>
        /// <param name="compulsory"></param>
        /// <returns></returns>
        public static OAttachment GenerateExcelFile(DataTable table, string filePath, string workSheetName, int compulsory)
        {
            Workbook workbook = new Workbook();
            Worksheet worksheet = new Worksheet(workSheetName);
            workbook.Worksheets.Add(worksheet);

            int totalRow = table.Rows.Count;
            int totalCol = table.Columns.Count;
            int rowNumber = 1;
            
            //column header
            for (int i = 0; i < totalCol; i++)
            {
                worksheet.Cells[0, i] = new Cell(table.Columns[i].ColumnName);

                if (i < compulsory)
                    worksheet.Cells[0, i].Format = new CellFormat(CellFormatType.Text, "[Red]");
                else
                    worksheet.Cells[0, i].Format = new CellFormat(CellFormatType.Text, "[Blue]");
            }

            //fill cells with data.  
            foreach (DataRow row in table.Rows)
            {
                for (int j = 0; j < totalCol; j++)
                {
                    ushort maxWidth = (ushort)12000;
                    ushort minWidth = (ushort)2000;
                    ushort currentWidth = minWidth;
                    try
                    {
                        if(row[j].GetType() == typeof(decimal))
                            worksheet.Cells[rowNumber, j] = new Cell(row[j], CellFormat.Decimal);
                        else if (row[j].GetType() == typeof(int))
                            worksheet.Cells[rowNumber, j] = new Cell(row[j], new CellFormat(CellFormatType.Number, "#,##0"));
                        else
                            worksheet.Cells[rowNumber, j] = new Cell(row[j].ToString(),CellFormat.General);
                    }
                    catch
                    {
                        worksheet.Cells[rowNumber, j] = new Cell(row[j].ToString());
                    }
                    worksheet.Cells.ColumnWidth[(ushort)j, (ushort)j] = minWidth;
                    if (worksheet.Cells[rowNumber, j].Value.ToString() != "")
                    {
                        ushort dataLength = (ushort)(worksheet.Cells[rowNumber, j].Value.ToString().Length * 256 * 1.5);
                        ushort width = dataLength > maxWidth ? maxWidth :
                            (dataLength > currentWidth ? dataLength : currentWidth);
                        worksheet.Cells.ColumnWidth[(ushort)j, (ushort)j] = width;
                    }
                }
                rowNumber++;
            }

            // to format cell in general format, 
            // or else when input number value, value would be formatted in date format 
            // instead of number format.
            // 2011.10.04, Kien Trung
            // Not necessary.
            /**************
            int lastRowIndex = worksheet.Cells.LastRowIndex;
            for (int i = lastRowIndex + 1; i < lastRowIndex + 100; i++)
                for (int j = 0; j < totalCol; j++)
                    worksheet.Cells[i, j] = new Cell("", CellFormat.General);            
            *****************/

            OAttachment attachment = SaveExcelFile(workbook, filePath, workSheetName);

            return attachment;
        }

        protected static OAttachment SaveExcelFile(Workbook workbook, string filePath, string fileName)
        {
            try
            {
                workbook.Save(filePath);
                FileStream sourceFile = new FileStream(filePath, FileMode.Open, FileAccess.Read);

                long fileSize;
                fileSize = sourceFile.Length;
                byte[] fileContent = new byte[(int)fileSize];
                sourceFile.Read(fileContent, 0, (int)fileSize);

                OAttachment file = TablesLogic.tAttachment.Create();
                file.FileBytes = fileContent;
                file.Filename = fileName + ".xls";
                file.ContentType = "application/vnd.ms-excel";
                sourceFile.Close();
                sourceFile.Dispose();
                return file;
            }
            catch (Exception ex)
            {
                ex.StackTrace.ToString();
            }
            return null;
        }

        /// <summary>
        /// Generates CSV File from input datatable.
        /// </summary>
        /// <param name="dtReports"></param>
        /// <param name="filename"></param>
        /// <returns></returns>
        public static OAttachment ExportDataTableToCsv(DataTable dtReports, string filename)
        {
            MemoryStream mem = new MemoryStream();
            StreamWriter sw = new StreamWriter(mem);
            for (int i = 0; i < dtReports.Columns.Count; i++)
            {
                if (i < dtReports.Columns.Count - 1)
                    sw.Write(dtReports.Columns[i].ColumnName + ",");
                else
                    sw.Write(dtReports.Columns[i].ColumnName);
            }

            foreach (DataRow row in dtReports.Rows)
            {
                sw.WriteLine();
                for (int i = 0; i < dtReports.Columns.Count; i++)
                {
                    if (i < dtReports.Columns.Count - 1)
                        sw.Write("\"" + row[i].ToString().Trim().Replace("\n", " ").Replace("\r", " ").Replace("\n\r", " ") + "\"" + ",");
                    else
                        sw.Write("\"" + row[i].ToString().Trim().Replace("\n", " ").Replace("\r", " ").Replace("\n\r", " ") + "\"");
                }
            }

            OAttachment file = TablesLogic.tAttachment.Create();
            sw.Close();
            file.FileBytes = mem.ToArray();
            mem.Close();
            file.Filename = filename + ".csv";
            file.ContentType = "text/csv";
            return file;
        }

    }
}
