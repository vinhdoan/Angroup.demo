using System;

namespace Pop3
{
	/// <summary>
	/// Summary description for Credentials.
	/// </summary>
	public class Pop3Credential
	{
		private string m_user;
		private string m_pass;
        private string m_server;
        private int? m_port;

		private string[] m_sendStrings = { "user", "pass" };

		public string[] SendStrings
		{
			get { return m_sendStrings; }
		}
		
		public string User
		{
			set { m_user = value; }
			get { return m_user; }
		}

		public string Pass
		{
			set { m_pass = value; }
			get { return m_pass; }
		}

		public string Server
		{
			set { m_server = value; }
			get { return m_server; }
		}

        public int? Port
        {
            set { m_port = value; }
            get { return m_port; }
        }
        public Pop3Credential(string user, string pass, string server, int? port)
		{
			m_user = user;
			m_pass = pass;
            m_server = server;
            m_port = port;
		}

		public Pop3Credential()
		{
			m_user = null;
			m_pass = null;
            m_server = null;
            m_port = null;            
		}
	}
}
