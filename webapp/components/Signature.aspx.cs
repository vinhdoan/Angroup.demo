using System;
using System.Data;
using System.Configuration;
using System.Collections;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;
using Anacle.DataFramework;
using LogicLayer;
using System.Drawing;
using System.Drawing.Imaging;
using System.IO;

public partial class components_Signature : System.Web.UI.Page
{
    private string Delimiter = ",";
    private string EndOfLine = "/";

    #region Line To Draw
    private struct LineToDraw
    {
        public int StartX;
        public int StartY;
        public int EndX;
        public int EndY;
        public byte StartByteX;
        public byte StartByteY;
        public byte EndByteX;
        public byte EndByteY;
    }
    #endregion

    protected void Page_Load(object sender, EventArgs e)
    {

        OWork a = null;
        if (Request["ID"] != null)
        {
            a = TablesLogic.tWork[Security.DecryptGuid(Request["ID"])];
        }

        if (a != null)
        {
            if (Request["Accept"] != null && a.AcceptSignature != null && a.AcceptSignature.Length > 0)
            {
                Response.ContentType = "image/bmp";
                Response.BinaryWrite(this.GetBimapVector(a.AcceptSignature));
                Response.End();
            }
            else if (Request["Usage"] != null && a.UsageSignature != null && a.UsageSignature.Length > 0)
            {
                Response.ContentType = "image/bmp";
                Response.BinaryWrite(this.GetBimapVector(a.UsageSignature));
                Response.End();
            }
        }

    }


    private byte[] GetBimapVector(byte[] contentVectorsBitmap)
    {
        Bitmap sign = new Bitmap(230, 184);
        Graphics graphic = Graphics.FromImage(sign);
        graphic.FillRectangle(new SolidBrush(System.Drawing.Color.White),
                                            0,
                                            0,
                                            sign.Size.Width,
                                            sign.Size.Height);
        ArrayList Points = new ArrayList();
        LineToDraw l;
        if (contentVectorsBitmap != null && contentVectorsBitmap.Length > 0 && contentVectorsBitmap.Length % 4 == 0)
        {
            for (int i = 0; i < contentVectorsBitmap.Length; i += 4)
            {
                l = new LineToDraw();
                l.StartByteX = contentVectorsBitmap[i];
                l.StartByteY = contentVectorsBitmap[i + 1];
                l.EndByteX = contentVectorsBitmap[i + 2];
                l.EndByteY = contentVectorsBitmap[i + 3];

                l.StartX = l.StartByteX;
                l.StartY = l.StartByteY;
                l.EndX = l.EndByteX;
                l.EndY = l.EndByteY;

                Points.Add(l);

            }
            try
            {
                if (Points.Count < 1) { return null; }
                Pen _pen = new Pen(Color.Black, 2);
                for (int i = 0; i < Points.Count; i++)
                {
                    l = (LineToDraw)Points[i];
                    graphic.DrawLine(_pen, l.StartX, l.StartY, l.EndX, l.EndY);
                }
                MemoryStream ms = new MemoryStream();
                sign.Save(ms, ImageFormat.Bmp);
                return ms.ToArray();
            }
            catch (Exception)
            {
                sign.Dispose();
                return null;
            }
        }
        else
            return null;

    }

    private byte[] GetBitmap(String contentBitmap)
    {
        Bitmap sign = new Bitmap(230, 184);
        Graphics graphic = Graphics.FromImage(sign);
        graphic.FillRectangle(new SolidBrush(System.Drawing.Color.White),
                                            0,
                                            0,
                                            sign.Size.Width,
                                            sign.Size.Height);
        ArrayList Points = new ArrayList();
        LineToDraw l;
        if (contentBitmap != null && contentBitmap.Length > 0)
        {
            string[] lines = contentBitmap.Split(EndOfLine.ToCharArray());
            foreach (string lineOfContent in lines)
            {
                if (lineOfContent.Length > 0)
                {
                    string[] linesplit = lineOfContent.Split(Delimiter.ToCharArray());
                    l = new LineToDraw();
                    l.StartX = int.Parse(linesplit[0].ToString());
                    l.StartY = int.Parse(linesplit[1].ToString());
                    l.EndX = int.Parse(linesplit[2].ToString());
                    l.EndY = int.Parse(linesplit[3].ToString());
                    Points.Add(l);
                }
            }
            try
            {
                if (Points.Count < 1) { return null; }
                Pen _pen = new Pen(Color.Black, 2);
                for (int i = 0; i < Points.Count; i++)
                {
                    l = (LineToDraw)Points[i];
                    graphic.DrawLine(_pen, l.StartX, l.StartY, l.EndX, l.EndY);
                }
                MemoryStream ms = new MemoryStream();
                sign.Save(ms, ImageFormat.Bmp);
                return ms.ToArray();
            }
            catch (Exception)
            {
                sign.Dispose();
                return null;
            }

        }
        else
            return null;
    }
}
