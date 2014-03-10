<%@ page import="net.admin.User,be.mxs.common.util.db.*,java.sql.*,com.digitalpersona.uareu.*" %>

<%!
	private String ByteArrayToString(byte[] ba)
	{
	        StringBuilder strBuilder=new StringBuilder();
	        int ibyte;
	        for(int i=0;i<ba.length;i++)
	        {
	            ibyte= ba[i] & 0xFF;
	            if(ibyte<16)
	                strBuilder.append("0");
	            strBuilder.append(Integer.toHexString(ibyte));
	        }
	        return strBuilder.toString();
	}
	
	//Not needed on client side.  But may be needed on server.
	private static byte[] hexStringToByteArray(String s) {
	    int len = s.length();
	    byte[] data = new byte[len / 2];
	    for (int i = 0; i < len; i += 2) {
	        data[i / 2] = (byte) ((Character.digit(s.charAt(i), 16) << 4)
	                             + Character.digit(s.charAt(i+1), 16));
	    }
	    return data;
	}
%>
<%
	String personid="0";	
	long password=0;
	try{
		String fmd = request.getParameter("fmd");
		Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
		String sSql="select * from OC_FINGERPRINTS";
		if(request.getParameter("user")!=null){
			sSql="select a.*,b.userid from OC_FINGERPRINTS a,UsersView b where a.personid=b.personid";
		}
		PreparedStatement ps = conn.prepareStatement(sSql);
		ResultSet rs = ps.executeQuery();
		byte[] fingerprint=null;
		System.out.println("Initializing candidates");
		Engine.Candidate[] candidates=null;
		System.out.println("Destroy reader collection");
		UareUGlobal.DestroyReaderCollection();
		System.out.println("Get fingerprint engine");
		Engine engine = UareUGlobal.GetEngine();
		System.out.println("Get importer");
		Importer importer=UareUGlobal.GetImporter();
		Fmd[] dbFmd=new Fmd[1];
		while (rs.next()){
			System.out.println("Got patient fingerprint");
			fingerprint=rs.getBytes("template");
			try{
				dbFmd[0]=importer.ImportFmd(fingerprint,Fmd.Format.ISO_19794_2_2005,Fmd.Format.ISO_19794_2_2005);
				Fmd thisFmd=importer.ImportFmd(hexStringToByteArray(fmd),Fmd.Format.ISO_19794_2_2005,Fmd.Format.ISO_19794_2_2005);
				candidates=engine.Identify(thisFmd,0,dbFmd,2147,1);
				System.out.println("candidates: "+candidates.length);
				if(candidates.length>0){
					if(request.getParameter("user")==null){
						personid=rs.getString("personid");
					}
					else{
						personid=rs.getString("userid");
						User user= User.get(Integer.parseInt(personid));
						password=User.hashPassword(user.password);
					}
					break;
				}
			}
			catch(Exception e2){
				e2.printStackTrace();
			}
		}
		UareUGlobal.DestroyReaderCollection();
		rs.close();
		ps.close();
		conn.close();
	}
	catch(Exception e){
		e.printStackTrace();
	}
%>
{
	"personid":"<%=personid %>",
	"password":"<%=password+"" %>"
}

