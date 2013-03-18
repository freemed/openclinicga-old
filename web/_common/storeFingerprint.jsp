<%@ page import="be.mxs.common.util.db.*,java.sql.*,com.digitalpersona.uareu.*" %>
<%@include file="/includes/validateUser.jsp"%>

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
	try{
		String fmd = request.getParameter("fmd");
		String rightleft = request.getParameter("rightleft");
		String finger = request.getParameter("finger");
		Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
		PreparedStatement ps = conn.prepareStatement("delete from OC_FINGERPRINTS where personid=? and finger=?");
		ps.setInt(1,Integer.parseInt(activePatient.personid));
		ps.setString(2,rightleft+finger);
		ps.execute();
		ps.close();		
		ps = conn.prepareStatement("insert into OC_FINGERPRINTS(personid,finger,template) values(?,?,?)");
		ps.setInt(1,Integer.parseInt(activePatient.personid));
		ps.setString(2,rightleft+finger);
		ps.setBytes(3,hexStringToByteArray(fmd));
		ps.execute();
		ps.close();		
		conn.close();
	}
	catch(Exception e){
		e.printStackTrace();
	}
%>