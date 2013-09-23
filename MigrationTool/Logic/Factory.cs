using System;
using System.Collections.Generic;
using System.Text;

using System.Reflection;

namespace DataMigration.Logic
{
    public class Factory
    {
        public static Migratable Create(string mapfrom, string mapto)
        {
            try
            {
                string handler = Infrastructure.Configuration.GetMigrateConfig(mapto).Handler;

                Type t = Type.GetType(handler);

                //Type t = Type.GetType("DataMigration.Logic.GeneralHandler");

                return (Migratable)Activator.CreateInstance(t, new object[] { mapfrom, mapto });
            }
            catch(Exception e)
            {
                throw new ApplicationException("Couldn't create handler to perform this migration.",e);
            }
        }

        public static Migratable Create(string mapfrom, string mapto, string sourcefile)
        {
            try
            {
                string handler = Infrastructure.Configuration.GetMigrateConfig(mapto).Handler;

                Type t = Type.GetType(handler);

                //Type t = Type.GetType("DataMigration.Logic.GeneralHandler");

                return (Migratable)Activator.CreateInstance(t, new object[] { mapfrom, mapto, sourcefile });
            }
            catch (Exception e)
            {
                throw new ApplicationException("Couldn't create handler to perform this migration.", e);
            }
        }

    }
}
