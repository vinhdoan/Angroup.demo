//========================================================================
// $Product: Abell Enterprise Asset Management
// $Version: 5.0
//
// Copyright 2006 (c) Anacle Systems Pte. Ltd.
// All rights reserved.
//========================================================================
using System;
using System.IO.Ports;
using System.Configuration;
using System.Collections.Generic;
using System.Text;
using LogicLayer;
using System.Collections;
using System.Transactions;
using Anacle.DataFramework;

namespace Service
{
    /// <summary>
    /// Represents a set of methods for communicating with an SMS modem 
    /// through a serial port.
    /// </summary>
    public class SmsCommunication
    {
        /// <summary>
        /// Logs a message into the background service log
        /// </summary>
        /// <param name="logMessage"></param>
        public static void LogEvent(string logMessage)
        {
            LogEvent(logMessage, BackgroundLogMessageType.Information);
        }

        /// <summary>
        /// Logs a message into the background service log
        /// </summary>
        /// <param name="logMessage"></param>
        public static void LogEvent(string logMessage, BackgroundLogMessageType messageType)
        {
            using (TransactionScope t = new TransactionScope(TransactionScopeOption.Suppress))
            {
                using (Connection c = new Connection())
                {
                    OBackgroundServiceLog log = TablesLogic.tBackgroundServiceLog.Create();
                    log.ServiceName = GlobalService.ServiceName + ": " + "SmsCommunication";
                    log.MessageType = (int)messageType;
                    log.Message = logMessage;
                    log.Save();
                    c.Commit();
                }
            }
        }

        /// <summary>
        /// Log message to log file in the server.
        /// </summary>
        /// <param name="message"></param>
        protected static void LogFile(string message)
        {
            try
            {
                string logPath = String.Format(AnacleServiceBase.ApplicationSetting.MessageSmsLogFilePath, DateTime.Now);

                Console.WriteLine(message);
                System.IO.StreamWriter sw = new System.IO.StreamWriter(logPath, true);
                if (sw != null)
                {
                    sw.WriteLine(DateTime.Now.ToString("yyyy-MM-dd hh:mm:ss.fff") + ": " + message);
                    sw.Close();
                }
                
            }
            catch
            {
            }
        }


        // --------------------------------------------------------------
        /// <summary>
        /// Write the specified text to the port.
        /// </summary>
        /// <param name="port"></param>
        /// <param name="message"></param>
        // --------------------------------------------------------------
        protected static void WritePort(SerialPort port, string message)
        {
            port.Write(message);
            LogFile("Write: " + message);
            System.Threading.Thread.Sleep(1000);
        }


        // --------------------------------------------------------------
        /// <summary>
        /// Write the specified text to the port with a new line.
        /// </summary>
        /// <param name="port"></param>
        /// <param name="message"></param>
        // --------------------------------------------------------------
        protected static void WriteLinePort(SerialPort port, string message)
        {
            port.WriteLine(message);
            LogFile("Write: " + message);
            System.Threading.Thread.Sleep(1000);
        }


        // --------------------------------------------------------------
        /// <summary>
        /// Wait for the specified string to be returned by the modem
        /// </summary>
        /// <param name="port"></param>
        /// <param name="strToWait"></param>
        /// <returns></returns>
        /// --------------------------------------------------------------
        protected static bool Wait(SerialPort port, string strToWait)
        {
            try
            {
                for (int i = 0; i < 10; i++)
                {
                    port.ReadTimeout = 30000;
                    string s = port.ReadLine();
                    LogFile("Read: " + s);
                    if (s.Contains(strToWait))
                        return true;
                    if (s.Contains("ERROR"))
                        return false;
                }
                return false;
            }
            catch (Exception ex)
            {
                LogFile("Exception: " + ex.Message);
                throw ex;
            }
        }


        // --------------------------------------------------------------
        /// <summary>
        /// Wait for the specified byte to be returned by the modem
        /// </summary>
        /// <param name="port"></param>
        /// <param name="strToWait"></param>
        /// <returns></returns>
        /// --------------------------------------------------------------
        protected static bool Wait(SerialPort port, int byteToWait)
        {
            try
            {
                for (int i = 0; i < 30; i++)
                {
                    port.ReadTimeout = 30000;
                    int s = port.ReadByte();
                    LogFile("Read byte: " + (char)s);
                    if (s == byteToWait)
                        return true;
                }
                return false;
            }
            catch (Exception ex)
            {
                LogFile("Exception: " + ex.Message);
                throw ex;
            }
        }


        /// --------------------------------------------------------------
        /// <summary>
        /// Read all the strings returned by the modem, until the
        /// one specified in strToWait. All strings returned by the modem
        /// are delimited with the '\n' character.
        /// </summary>
        /// <param name="port"></param>
        /// <param name="strToWait"></param>
        /// <returns></returns>
        /// --------------------------------------------------------------
        protected static string WaitAndRead(SerialPort port, string strToWait)
        {
            string read = "";
            for (int i = 0; i < 20; i++)
            {
                port.ReadTimeout = 30000;
                string s = port.ReadLine();
                LogFile("Read: " + s);
                read += s + "\n";
                if (s.Contains(strToWait))
                    return read;
                if (s.Contains("ERROR"))
                    return null;
            }
            return null;
        }


        /// --------------------------------------------------------------
        /// <summary>
        /// Opens the SMS modem and initializes it. 
        /// 
        /// The AT commands sent to the SMS modem should initialize the
        /// following:
        /// 1. Turn off the modem echo. (ATE0)
        /// 2. Set format to text (AT+CMGF=1)
        /// 3. Set the SMS center (AT+CSCA={centre number})
        /// 
        /// </summary>
        /// <returns></returns>
        /// --------------------------------------------------------------
        protected static SerialPort OpenPort()
        {
            SerialPort port = null;
            try
            {
                port =
                    new SerialPort(
                    AnacleServiceBase.ApplicationSetting.MessageSmsComPort,
                    AnacleServiceBase.ApplicationSetting.MessageSmsBaudRate.Value,
                    (Parity)Enum.Parse(typeof(Parity), AnacleServiceBase.ApplicationSetting.MessageSmsParity),
                    AnacleServiceBase.ApplicationSetting.MessageSmsDataBits.Value,
                    (StopBits)Enum.Parse(typeof(StopBits), AnacleServiceBase.ApplicationSetting.MessageSmsStopBits));
                System.Threading.Thread.Sleep(1000);
                port.Open();
                port.Handshake = (Handshake)Enum.Parse(typeof(Handshake), AnacleServiceBase.ApplicationSetting.MessageSmsHandshake);
                port.NewLine = AnacleServiceBase.ApplicationSetting.MessageSmsNewLine.
                    Replace("\\r", "\r").
                    Replace("\\n", "\n");

                // send a control-Z, just in case the modem is stuck in waiting
                // for an SMS input.
                //
                WritePort(port, Convert.ToChar(26).ToString());

                string initCommands = AnacleServiceBase.ApplicationSetting.MessageSmsInitCommands;
                string[] initCommandsSplit = initCommands.Split(';');
                //System.Threading.Thread.Sleep(200);
                foreach (string command in initCommandsSplit)
                {
                    WriteLinePort(port, command);
                    Wait(port, "OK");
                }

                return port;
            }
            catch (Exception ex)
            {
                if (port != null)
                    port.Close();
                throw ex;
            }
            return null;
        }


        /// --------------------------------------------------------------
        /// <summary>
        /// Send SMS (non-Unicode)
        /// </summary>
        /// <param name="recipient"></param>
        /// <param name="messageBody"></param>
        /// <returns></returns>
        /// --------------------------------------------------------------
        protected static bool SendASCII(string recipient, string messageBody)
        {
            SerialPort port = null;
            try
            {
                // Adds a '+' if we determine the recipient's number
                // to be a non-local number.
                //
                int localNumberDigits = 8;
                if (OApplicationSetting.Current.MessageSmsLocalNumberDigits != null)
                    localNumberDigits = OApplicationSetting.Current.MessageSmsLocalNumberDigits.Value;
                recipient = recipient.Trim();
                if (recipient.Length != localNumberDigits &&
                    !recipient.StartsWith("+"))
                    recipient = "+" + recipient;

                port = OpenPort();
                string fullMessage = messageBody;
                int messageLength = 160;

                WriteLinePort(port, AnacleServiceBase.ApplicationSetting.MessageSmsInitASCIICommand);
                Wait(port, "OK");

                for (int i = 0; i < fullMessage.Length; i = i + messageLength)
                {
                    string partialMessage = "";
                    if (fullMessage.Length - i >= messageLength)
                        partialMessage = fullMessage.Substring(i, messageLength);
                    else
                        partialMessage = fullMessage.Substring(i, fullMessage.Length - i);
                    WriteLinePort(port, String.Format(AnacleServiceBase.ApplicationSetting.MessageSmsSendCommands, recipient));
                    System.Threading.Thread.Sleep(1000);
                    Wait(port, '>');
                    WritePort(port, partialMessage + Convert.ToChar(26));
                    if (!Wait(port, "+CMGS"))
                    {
                        LogFile("Unable to send SMS");
                        throw new Exception("Unable to send SMS");
                    }
                    System.Threading.Thread.Sleep(1000);
                    LogFile("Read: " + port.ReadExisting());
                }
            }
            finally
            {
                if (port != null)
                    port.Close();
            }

            return true;
        }


        /// --------------------------------------------------------------
        /// <summary>
        /// Send SMS (unicode)
        /// </summary>
        /// <param name="recipient"></param>
        /// <param name="messageBody"></param>
        /// <returns></returns>
        /// --------------------------------------------------------------
        protected static bool SendUCS2(string recipient, string messageBody)
        {
            SerialPort port = null;
            StringBuilder sb = new StringBuilder();

            try
            {
                // Adds a '+' if we determine the recipient's number
                // to be a non-local number.
                //
                int localNumberDigits = 8;
                if (OApplicationSetting.Current.MessageSmsLocalNumberDigits != null)
                    localNumberDigits = OApplicationSetting.Current.MessageSmsLocalNumberDigits.Value;
                recipient = recipient.Trim();
                if (recipient.Length != localNumberDigits &&
                    !recipient.StartsWith("+"))
                    recipient = "+" + recipient;

                port = OpenPort();

                // convert it to hexadecimal UCS2 encoding
                //
                for (int i = 0; i < messageBody.Length; i++)
                    sb.Append(((int)messageBody[i]).ToString("X4"));
                string fullMessage = sb.ToString();

                // = 80*4 because each character must be represented in 4 hexadecimal characters
                //
                int messageLength = 320;

                WriteLinePort(port, AnacleServiceBase.ApplicationSetting.MessageSmsInitUCS2Command);
                port.Encoding = Encoding.ASCII;
                Wait(port, "OK");

                for (int i = 0; i < fullMessage.Length; i = i + messageLength)
                {
                    string partialMessage = "";
                    if (fullMessage.Length - i >= messageLength)
                        partialMessage = fullMessage.Substring(i, messageLength);
                    else
                        partialMessage = fullMessage.Substring(i, fullMessage.Length - i);
                    WriteLinePort(port, String.Format(AnacleServiceBase.ApplicationSetting.MessageSmsSendCommands, recipient));
                    System.Threading.Thread.Sleep(1000);
                    Wait(port, '>');
                    WritePort(port, partialMessage + Convert.ToChar(26));
                    if (!Wait(port, "+CMGS"))
                    {
                        LogFile("Unable to send SMS");
                        throw new Exception("Unable to send SMS");
                    }
                    System.Threading.Thread.Sleep(1000);
                    LogFile("Read: " + port.ReadExisting());
                }

            }
            finally
            {
                if (port != null)
                    port.Close();
            }

            return true;
        }



        /// --------------------------------------------------------------
        /// <summary>
        /// This method first tests if the message contains any unicode 
        /// characters, and will try to send it out with UCS2 encoding
        /// if so.
        /// </summary>
        /// <param name="recipient"></param>
        /// <param name="messageBody"></param>
        /// <returns></returns>
        /// --------------------------------------------------------------
        public static bool Send(string recipient, string messageBody)
        {
            bool hasUnicodeCharacters = false;
            
            for( int i=0; i<messageBody.Length; i++ )
                if ((int)messageBody[i] > 255)
                {
                    hasUnicodeCharacters = true;
                    break;
                }

            if (hasUnicodeCharacters)
                return SendUCS2(recipient, messageBody);
            else
                return SendASCII(recipient, messageBody);
        }


        /// --------------------------------------------------------------
        /// <summary>
        /// Receive SMS from the modem and remove it from the queue. 
        /// 
        /// Only the first SMS in the queue will be received by this 
        /// method. Subsequent messages can be obtained by calling this
        /// method repeatedly until the method returns false.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="messageBody"></param>
        /// <returns></returns>
        /// --------------------------------------------------------------
        public static bool Receive(out string sender, out string messageBody)
        {
            SerialPort port = null;

            try
            {
                port = OpenPort();
                
                sender = "";
                messageBody = "";

                for (int i = 1; i < 50; i++)
                {
                    WriteLinePort(port, String.Format(AnacleServiceBase.ApplicationSetting.MessageSmsReceiveCommands, i));
                    string s = WaitAndRead(port, "OK");

                    if (s != null && s.Contains("+CMGR"))
                    {
                        LogEvent(s);

                        // decode the SMS
                        //
                        string[] l = s.Split('\n');
                        for (int j = 0; j < l.Length; j++)
                        {
                            if (l[j].Contains("+CMGR"))
                            {
                                string[] c = l[j].Split(',');

                                if (c.Length >= 2)
                                    sender = c[1].Replace("\"", "").Trim();

                                for (int k = j + 1; k < l.Length; k++)
                                {
                                    if (l[k].Trim() == "OK")
                                        break;
                                    else
                                        messageBody += l[k].Trim();
                                }

                                break;
                            }
                        }
                        // delete the SMS from the SIM card
                        //
                        if (sender != "")
                        {
                            WriteLinePort(port, String.Format(AnacleServiceBase.ApplicationSetting.MessageSmsDeleteCommands, i));
                            Wait(port, "OK");
                            port.Close();
                            return true;
                        }
                    }
                }
            }
            finally
            {
                if( port!=null )
                    port.Close();
            }

            return false;
        }
    }
}
