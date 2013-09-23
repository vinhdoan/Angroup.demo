//========================================================================
// $Product: Simplism Enterprise Asset Management
// $Version: 1.0
//
// All rights reserved.
//========================================================================
using System;
using System.IO;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Text;
using System.Text.RegularExpressions;

/// <summary>
/// Summary description for MhtProcessor
/// </summary>
public class MhtProcessor
{
    /// <summary>
    /// Split.  
    /// </summary>
    public static bool IsMhtContent(string content)
    {
        if (content.StartsWith("MIME-Version:"))
            return true;
        return false;
    }


    private static string FindAndExtractProperty(string content, string propertyPrefix)
    {
        Regex r = new Regex(propertyPrefix + ".+");
        string tag = r.Match(content).Groups[0].Value;
        return tag.Replace(propertyPrefix, "").Replace("\"", "").Trim();
    }


    /// <summary>
    /// Split.  
    /// </summary>
    public static string SplitMhtContent(string content, string outputPath)
    {
        string boundaryTag = FindAndExtractProperty(content, "boundary=");
        if (boundaryTag == "")
            return "";
        boundaryTag = "--" + boundaryTag;

        string[] files = content.Split(new string[] { boundaryTag }, StringSplitOptions.None);

        // 2011.09.20, Kien Trung
        // FIXED: Do not hard code drive file path.
        // e.g: temp folder can be in E: drive or any other drive.
        //
        string driveFilePath = "";
        string firstFilePath = "";
        foreach (string file in files)
        {
            string contentLocation = FindAndExtractProperty(file, "Content-Location:");
            string contentEncoding = FindAndExtractProperty(file, "Content-Transfer-Encoding:");
            string contentType = FindAndExtractProperty(file, "Content-Type:");

            if (contentLocation == "")
                continue;

            // 2011.09.20, Kien Trung
            // FIXED: Do not hard code drive file path.
            // e.g: temp folder can be in E: drive or any other drive.
            //
            if (driveFilePath == "")
                driveFilePath = (outputPath[0].ToString() + outputPath[1].ToString()).ToUpper();

            contentLocation = contentLocation.Replace("file:///" + driveFilePath + "/", outputPath).Replace("file:///" + driveFilePath + "/", outputPath).Replace("/", "\\");
            string contentPath = Path.GetDirectoryName(contentLocation);
            Directory.CreateDirectory(contentPath);

            int blankIndex = file.IndexOf("\r\n\r\n");
            string fileContent = file.Substring(blankIndex + 4).Trim();

            if (firstFilePath == "")
                firstFilePath = contentLocation;

            if (contentEncoding.Trim() == "base64" && !contentType.Contains("image"))
            {
                fileContent = fileContent.Replace("\r", "").Replace("\n", "");
                FileStream fs = new FileStream(contentLocation, FileMode.Create);
                byte[] contentBytes = Convert.FromBase64String(fileContent);
                fs.Write(contentBytes, 0, contentBytes.Length);
                fs.Close();
            }
            else
            {
                StreamWriter sw = new StreamWriter(contentLocation);
                fileContent = fileContent.Replace("=\r\n", "").Replace("=\n", "").Replace("=\r", "").Replace("=3D", "=");
                sw.Write(fileContent);
                sw.Close();
            }
        }
        return firstFilePath;
    }
}
