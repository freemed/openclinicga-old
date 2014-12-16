<%@page import="be.mxs.common.util.db.*,
                java.sql.*,
                com.digitalpersona.uareu.*"%>
<%@include file="/includes/validateUser.jsp"%>

<%!	
    //--- HEX STRING TO BYTE ARRAY ----------------------------------------------------------------
	// Not needed on client side.  But may be needed on server.
	private static byte[] hexStringToByteArray(String s){
	    int len = s.length();
	    byte[] data = new byte[len / 2];
	    for(int i=0; i<len; i+=2){
	        data[i/2] = (byte)((Character.digit(s.charAt(i),16) << 4)+
	        		            Character.digit(s.charAt(i+1),16));
	    }
	    return data;
	}
%>

<%
    String fmd       = checkString(request.getParameter("fmd")),
           rightleft = checkString(request.getParameter("rightleft")),
           finger    = checkString(request.getParameter("finger"));

    /// DEBUG /////////////////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
    	Debug.println("\n********************** _common/storeFingerprint.jsp ********************");
    	Debug.println("fmd       : "+fmd);
    	Debug.println("rightleft : "+rightleft);
    	Debug.println("finger    : "+finger+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////

	try{		
		// delete existing prints for person
		Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
		PreparedStatement ps = conn.prepareStatement("delete from OC_FINGERPRINTS where personid=? and finger=?");
		ps.setInt(1,Integer.parseInt(activePatient.personid));
		ps.setString(2,rightleft+finger);
		ps.execute();
		ps.close();		
		
		// store new print
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