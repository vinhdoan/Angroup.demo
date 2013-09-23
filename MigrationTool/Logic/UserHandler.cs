using System;
using System.Collections;
using System.Collections.Generic;
using System.Text;
using System.Text.RegularExpressions;
using System.Data;
using Anacle.DataFramework;
using LogicLayer;

namespace DataMigration.Logic
{
    public class UserHandler : Migratable
    {
        public UserHandler(string mapfrom, string mapto)
            : base(mapfrom, mapto)
        { }

        public UserHandler(string mapfrom, string mapto, string sourcefile)
            : base(mapfrom, mapto, sourcefile)
        { }

        public override void Migarate()
        {
            try
            {
                DataTable table = GetDatasource();

                ImportUserHandler(table);
                Infrastructure.LogHelper.LogDataImport(mapfrom, table, this.Map.Values);
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        public void Migarate(bool assignTypeOfSvcOnly)
        {
            try
            {
                DataTable table = GetDatasource();
                ImportUserHandler(table);
                Infrastructure.LogHelper.LogDataImport(mapfrom, table, this.Map.Values);
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }


        private string IsNull(string v, string alt)
        {
            if (v == null) return alt;
            return v;
        }


        private void ImportUserHandler(DataTable table)
        {
            string errTest = "";

            List<OPosition> positions = TablesLogic.tPosition.LoadAll();
            Hashtable h = new Hashtable();
            foreach (OPosition position in positions)
                h[position.ObjectName] = position;

            foreach (DataRow dr in table.Rows)
            {
                try
                {
                    string UserName = ConvertToString(dr[map["User Name"]]);
                    string LoginName = ConvertToString(dr[map["Login Name"]]);
                    string Positions = ConvertToString(dr[map["Positions"]]);
                    string CellPhone = ConvertToString(dr[map["Cell Phone"]]);
                    string Fax = ConvertToString(dr[map["Fax"]]);
                    string Email = ConvertToString(dr[map["Email"]]);
                    string Phone = ConvertToString(dr[map["Phone"]]);
                    string Country = ConvertToString(dr[map["Country"]]);
                    string State = ConvertToString(dr[map["State"]]);
                    string City = ConvertToString(dr[map["City"]]);
                    string Address = ConvertToString(dr[map["Address"]]);
                    int len10 = 0;

                    if (LoginName == null || LoginName.ToString() == string.Empty)
                        throw new Exception("Login Name can not be left empty");
                    errTest = "1";
                    if (UserName == null || UserName.ToString() == string.Empty)
                        throw new Exception("UserName can not be left empty");
                    errTest = "2";
                    //OUser user = null;
                    OUser user = TablesLogic.tUser.Load(
                           TablesLogic.tUser.UserBase.LoginName == LoginName &
                           TablesLogic.tUser.IsDeleted == 0);
                    bool isUserExisted = TablesLogic.tUser.Load(
                           TablesLogic.tUser.UserBase.LoginName == LoginName &
                           TablesLogic.tUser.IsDeleted == 0) != null;
                    OUserBase userbase = null;
                    errTest = "4";

                    if (user == null)
                    {
                        errTest = "5";
                        user = TablesLogic.tUser.Create();
                    }
                    userbase = user.UserBase;
                    if (userbase == null)
                    {
                        errTest = "6";
                        userbase = TablesLogic.tUserBase.Create();
                        user.UserBase = userbase;
                    }

                    user.ObjectName = UserName;
                    user.LanguageName = "en-US";
                    user.ThemeName = "Corporate";
                    userbase.LoginName = LoginName;
                    errTest = "7";
                    errTest = "8";
                    userbase.UserName = "";
                    if (!isUserExisted || !String.IsNullOrEmpty(Address))
                        userbase.Address = IsNull(Address, "");
                    if (!isUserExisted || !String.IsNullOrEmpty(City))
                        userbase.AddressCity = IsNull(City, "");
                    if (!isUserExisted || !String.IsNullOrEmpty(Phone))
                        userbase.Phone = IsNull(Phone, "");
                    if (!isUserExisted || !String.IsNullOrEmpty(CellPhone))
                        userbase.Cellphone = IsNull(CellPhone, "");
                    if (!isUserExisted || !String.IsNullOrEmpty(State))
                        userbase.AddressState = IsNull(State, "");
                    if (!isUserExisted || !String.IsNullOrEmpty(Email))
                        userbase.Email = IsNull(Email, "");
                    if (!isUserExisted || !String.IsNullOrEmpty(Fax))
                        userbase.Fax = IsNull(Fax, "");
                    if (!isUserExisted || !String.IsNullOrEmpty(Country))
                        userbase.AddressCountry = IsNull(Country, "");

                    //Append positions instead
                    //user.PermanentPositions.Clear();

                    string[] positionNames = Positions.Split('|');
                    foreach (string pos in positionNames)
                    {
                        if (String.IsNullOrEmpty(pos))
                            continue;

                        if (h[pos.Trim().Replace("\n","")] == null)
                            throw new Exception("Unable to find position '" + pos.Trim() + "'");
                            //continue;

                        OUserPermanentPosition up = TablesLogic.tUserPermanentPosition.Create();
                        up.PositionID = ((OPosition)h[pos.Trim()]).ObjectID;
                        user.PermanentPositions.Add(up);
                    }

                    errTest = "9";
                    //testing: throw new Exception("invalid login name");

                    //if (ProjectCode == null || ProjectCode.ToString() == string.Empty)
                    //    throw new Exception("ProjectCode can not be left empty");

                    errTest = "16";
                    /* not needed in MOE
                    if (technician == 1) {
                        OCraft ocraft = TablesLogic.tCraft.Load(
                                     TablesLogic.tCraft.ObjectName == Craft.Trim() &
                                     TablesLogic.tCraft.IsDeleted == 0);
                        if (ocraft != null)
                            user.CraftID = ocraft.ObjectID;
                        else
                            throw new Exception("This Craft does not exist");
                    }
                    if (finance == 1)
                        user.BuyerNumber = Buyer;
                    */
                    errTest = "25";
                    user.UserBase = userbase;
                    errTest = "26";
                    SaveObject(user);
                    errTest = "27";
                    ActivateObject(user);
                }
                catch (Exception ex)
                {
                    dr[ERROR_MSG_COL] = ex.Message + errTest;
                }
            }
        }

    }
}