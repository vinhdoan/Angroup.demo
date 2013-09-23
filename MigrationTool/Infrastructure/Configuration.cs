using System;
using System.Collections.Generic;
using System.Text;
using System.Collections;

using System.Xml;


namespace DataMigration.Infrastructure
{
    public class Configuration
    {
        private static IDictionary<string, MigrationConfig> migrations;

        private static List<string> allMigrations;

        public static string configfile = "";
        //private const string configfile = "Migrations.xml";

        static Configuration()
        {
            //XmlDocument doc = new XmlDocument();

            //migrations = new Dictionary<string, MigrationConfig>();

            //allMigrations = new List<string>();

            //doc.Load(configfile);

            //XmlNodeList list = doc.SelectNodes("descendant::Migration");
            //foreach (XmlNode node in list)
            //{
            //    MigrationConfig migaration = new MigrationConfig(node);
            //    migrations.Add(migaration.Name, migaration);
            //    allMigrations.Add(migaration.Name);
            //}
        }

        public static void SetXMLFile(string name)
        {
            configfile = name;
            XmlDocument doc = new XmlDocument();

            migrations = new Dictionary<string, MigrationConfig>();

            allMigrations = new List<string>();

            doc.Load(configfile);

            XmlNodeList list = doc.SelectNodes("descendant::Migration");
            foreach (XmlNode node in list)
            {
                MigrationConfig migaration = new MigrationConfig(node);
                migrations.Add(migaration.Name, migaration);
                allMigrations.Add(migaration.Name);
            }
            allMigrations.Sort();

        }

        public static MigrationConfig GetMigrateConfig(string name)
        {
            if (migrations.ContainsKey(name))
            {
                return migrations[name];
            }
            return null;

        }

        public static List<string> AllMigrations
        {
            get
            {
                return allMigrations;
            }
        }


    }

    public class MigrationConfig
    {
        public MigrationConfig(XmlNode node)
        {
            this.name = node.Attributes["name"].Value;
            this.handler = node.Attributes["handler"].Value;

            //ArrayList fields = new ArrayList();

            fields = new List<string>();
            fieldtype = new List<string>();

            foreach (XmlNode field in node.SelectNodes("Fields/Field"))
            {
                //fields.Add(field.InnerText);
                //string[] attribute = new string[2];
                //attribute[0] = field.Attributes["name"].Value;
                //attribute[1] = field.Attributes["type"].Value;
                //fields.Add(field);

                fields.Add(field.Attributes["name"].Value);
                fieldtype.Add(field.Attributes["type"].Value);
            }
        }

        private string name;

        private string handler;

        //private ArrayList fields;
        private List<string> fields;

        public List<string> Fields
        {
            get
            {
                return fields;
            }
        }

        private List<string> fieldtype;

        public List<string> FieldType
        {
            get
            {
                return fieldtype;
            }
        }

        //public ArrayList Fields
        //{
        //    get
        //    {
        //        return fields;
        //    }
        //}

        public string Handler
        {
            get
            {
                return handler;
            }
        }

        public string Name
        {
            get
            {
                return name;
            }
        }


    }
}
