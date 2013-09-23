//========================================================================
// $Product: Anacle Enterprise Asset Management
// $Version: 6.0
//
// Copyright 2006 (c) Anacle Systems Pte. Ltd.
// All rights reserved.
//========================================================================
using System;
using System.Data;
using System.Configuration;
using System.Collections;
using System.Collections.Generic;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;
using System.IO;
using Anacle.DataFramework;

namespace LogicLayer
{
   
    public partial class TBMSTransmissionStatus : LogicLayerSchema<OBMSTransmissionStatus>
    {
        public SchemaDateTime BMSDate;
        public SchemaString FileName;
        public SchemaInt Status;
        public SchemaDateTime SucceededDate;
        public SchemaInt NumberOfRecords;
        public SchemaInt NumberOfRecordsImported;
        [Size(500)]
        public SchemaString Remarks;
        public SchemaGuid OPCDAServerID;
        public TBMSTransmissionStatusItem BMSTransmissionStatusItems { get { return OneToMany<TBMSTransmissionStatusItem>("BMSTransmissionStatusID"); } }
        public TOPCDAServer OPCDAServer { get { return OneToOne<TOPCDAServer>("OPCDAServerID"); } }
    }



    public abstract partial class OBMSTransmissionStatus : LogicLayerPersistentObject
    {
        public abstract DateTime? BMSDate { get; set; }
        public abstract string FileName { get; set; }
        public abstract int? Status { get; set; }
        public abstract DateTime? SucceededDate { get; set; }
        public abstract int? NumberOfRecords { get; set; }
        public abstract int? NumberOfRecordsImported { get; set; }
        public abstract string Remarks { get; set; }
        public abstract Guid? OPCDAServerID { get; set; }
        public abstract DataList<OBMSTransmissionStatusItem> BMSTransmissionStatusItems { get; set; }
        public abstract OOPCDAServer OPCDAServer { get; set; }
        public string StatusText
        {
            get
            {
                if (this.Status == 1)
                    return "Success";
                else
                    return "Fail";
            }
        }

        public static void GenerateReadingFromOPCDAServer(OOPCDAServer opc,bool isRetry)
        {
            OBMSTransmissionStatus BMSTransmissionStatus = TablesLogic.tBMSTransmissionStatus.Load(
                                                               TablesLogic.tBMSTransmissionStatus.OPCDAServerID == opc.ObjectID);
            if (BMSTransmissionStatus == null)
            {
                BMSTransmissionStatus = TablesLogic.tBMSTransmissionStatus.Create();
            }
            else
            {
                if(!isRetry | BMSTransmissionStatus.Status == BMSStatus.Success)
                    return;
            }
            BMSTransmissionStatus.OPCDAServerID = opc.ObjectID;
            int RemarksRunningNum = 0;
            #region File Validateion
            string filePath = opc.TextFilePathFormat;
            if (filePath == null || filePath.Trim().Length == 0)
            {
                BMSTransmissionStatus.Remarks = (RemarksRunningNum++) + ". BMS File Path is not specified.";
                SaveBMSTransmissionStatus(BMSTransmissionStatus, BMSStatus.Fail);
            }
            if (!File.Exists(filePath))
            {
                BMSTransmissionStatus.Remarks = (RemarksRunningNum++) + ". BMS File Path " + filePath + " does not exist or access denied.";
                SaveBMSTransmissionStatus(BMSTransmissionStatus, BMSStatus.Fail);
                return;
            }
            filePath = String.Format(filePath, DateTime.Now);
            string[] fileName = filePath.Split('\\');
            if (fileName == null || fileName.Length == 0)
            {
                BMSTransmissionStatus.Remarks = (RemarksRunningNum++) + ". BMS File Path is not specified.";
                SaveBMSTransmissionStatus(BMSTransmissionStatus, BMSStatus.Fail);
                return;
            }
            #endregion

            DateTime BMSDate = DateTime.Today;

            try
            {
                string[] date = fileName[fileName.Length - 1].Split('-');
                string[] name = date[date.Length-1].Split('.');
                BMSDate = new DateTime(Convert.ToInt16(name[0].Substring(0, 4)), Convert.ToInt16(name[0].Substring(4, 2)), Convert.ToInt16(name[0].Substring(6, 2)));
                BMSDate = BMSDate.AddDays(opc.BMSReadingDayDifference.Value);
            }
            catch(Exception ex)
            {
                BMSTransmissionStatus.Remarks = (RemarksRunningNum++) + ". BMS File Name is not a valid DateTime.";
                SaveBMSTransmissionStatus(BMSTransmissionStatus, BMSStatus.Fail);
                return;
            }


            List<String> bmscode = new List<string>();
            bool IsSuccess = true;
            int NumberOfRecords = 0;
            int NumberOfSuccessRecords = 0;
            Hashtable ListBMSCode = new Hashtable();
            List<String> BMSCodes = new List<string>();
            string Remarks = "";
            //read text file
            using (StreamReader sr = File.OpenText(filePath))
            {
                if (sr == null)
                {
                    BMSTransmissionStatus.Remarks = (RemarksRunningNum++) + ". BMS File Path " + filePath + " is empty file.";
                    SaveBMSTransmissionStatus(BMSTransmissionStatus, BMSStatus.Fail);
                    return;
                }
                string line = "";

                if (BMSTransmissionStatus.BMSTransmissionStatusItems.Count > 0)
                    BMSTransmissionStatus.BMSTransmissionStatusItems.Clear();

                while ((line = sr.ReadLine()) != null)
                {

                    if (line.Trim().Length == 0)
                        continue;
                    string[] s = line.Split(',');

                    if (s == null || s.Length == 0)
                        continue;
                    NumberOfRecords++;
                    OBMSTransmissionStatusItem bmsItem = TablesLogic.tBMSTransmissionStatusItem.Create();
                    bmsItem.RecordNo = NumberOfRecords;
                    bmsItem.BMSCode = s[0].Trim();
                    bmsItem.IsSuccess = BMSStatus.Success;

                    string header = "Record " + NumberOfRecords.ToString() + ". ";
                    if (s[0] == null || s[0] == String.Empty)
                    {
                        bmsItem.IsSuccess = BMSStatus.Fail;
                        Remarks += (RemarksRunningNum++) + ". " + header + "BMS Code is blank.<br />";
                        BMSTransmissionStatus.BMSTransmissionStatusItems.Add(bmsItem);
                        IsSuccess = false;
                        continue;
                    }

                    if (s.Length < 2)
                    {
                        bmsItem.IsSuccess = BMSStatus.Fail;
                        Remarks += (RemarksRunningNum++) + ". " + header + "has no reading.<br />";
                        BMSTransmissionStatus.BMSTransmissionStatusItems.Add(bmsItem);
                        IsSuccess = false;
                        continue;
                    }
                    else
                    {//check valid reading value
                        try
                        {
                            bmsItem.ReadingValue = decimal.Parse(s[1]);
                        }
                        catch (Exception)
                        {
                            bmsItem.IsSuccess = BMSStatus.Fail;
                            Remarks += (RemarksRunningNum++) + ". " + header + "reading is not a valid decimal value.<br />";
                            BMSTransmissionStatus.BMSTransmissionStatusItems.Add(bmsItem);
                            IsSuccess = false;
                            continue;
                        }

                    }
                    //check duplicate BMSCode in same text file
                    if (isBMSCodeDuplicated(s[0], ListBMSCode, decimal.Parse(s[1])))
                    {
                        bmsItem.IsSuccess = BMSStatus.Fail;
                        Remarks += (RemarksRunningNum++) + ". " + header + "is duplicate.<br />";
                        BMSTransmissionStatus.BMSTransmissionStatusItems.Add(bmsItem);
                        IsSuccess = false;
                        continue;
                    }
                    NumberOfSuccessRecords++;
                    BMSTransmissionStatus.BMSTransmissionStatusItems.Add(bmsItem);
                }
                BMSTransmissionStatus.NumberOfRecords = NumberOfRecords;
                BMSTransmissionStatus.NumberOfRecordsImported = NumberOfSuccessRecords;
                if (!IsSuccess)
                {
                    BMSTransmissionStatus.Remarks = Remarks;
                    SaveBMSTransmissionStatus(BMSTransmissionStatus, BMSStatus.Fail);
                }
                else
                {
                    //create new reading
                    foreach (object key in ListBMSCode.Keys)
                    {
                        string code = Convert.ToString(key);
                        decimal value = Convert.ToDecimal(ListBMSCode[key]);
                        List<OPoint> points = TablesLogic.tPoint.LoadList(
                                                TablesLogic.tPoint.BMSCode == code &
                                                TablesLogic.tPoint.IsActive == 1 &
                                                TablesLogic.tPoint.OPCDAServerID == opc.ObjectID);

                        using (Connection c = new Connection())
                        {
                            foreach (OPoint po in points)
                            {
                                if (!po.IsReadingWithTenantExist(null, DateTime.Today) &&
                                !po.IsReadingBackDate(null, DateTime.Today))
                                {
                                    OReading reading = TablesLogic.tReading.Create();
                                    reading.PointID = po.ObjectID;
                                    reading.Reading = Convert.ToDecimal(value);
                                    reading.DateOfReading = DateTime.Now;
                                    reading.Save();
                                }
                            }
                            c.Commit();
                        }
                    }
                    BMSTransmissionStatus.Remarks = Remarks;
                    BMSTransmissionStatus.SucceededDate = DateTime.Now;
                    SaveBMSTransmissionStatus(BMSTransmissionStatus, BMSStatus.Success);
                }
            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="BMSCode"></param>
        /// <param name="ListBMSCode"></param>
        /// <param name="Value"></param>
        /// <returns></returns>
        public static bool isBMSCodeDuplicated(string BMSCode, Hashtable ListBMSCode, decimal Value)
        {
            if (ListBMSCode[BMSCode] == null)
            {
                ListBMSCode.Add(BMSCode, Value);
                return false;
            }
            return true;
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="BMSTransmissionStatus"></param>
        /// <param name="Status"></param>
        public static void SaveBMSTransmissionStatus(OBMSTransmissionStatus BMSTransmissionStatus, int Status)
        {
            if (BMSTransmissionStatus == null)
                return;
            using (Connection c = new Connection())
            {
                if (Status == 0)
                {
                    BMSTransmissionStatus.Status = BMSStatus.Fail;
                    BMSTransmissionStatus.NumberOfRecordsImported = 0;
                }
                else
                {
                    BMSTransmissionStatus.Status = BMSStatus.Success;
                }
                BMSTransmissionStatus.Save();
                c.Commit();
            }

        }
       
    }
    public class BMSStatus
    {
        public static int Success = 1;
        public static int Fail = 0;
    }
}