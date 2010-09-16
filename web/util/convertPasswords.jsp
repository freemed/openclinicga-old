<%@page errorPage="/includes/error.jsp"%>
<%@page import="sun.misc.*"%>
<%@ page import="be.mxs.common.util.system.Debug" %>
<%@ page import="net.admin.User" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="be.mxs.common.util.db.MedwanQuery" %>
<%@ page import="java.sql.*" %>

<%!
    //--- ENCODE ----------------------------------------------------------------------------------
    public String encode(String sValue) {
        BASE64Encoder encoder = new BASE64Encoder();
        return encoder.encodeBuffer(sValue.getBytes());
    }

    //--- DECODE ----------------------------------------------------------------------------------
    public String decode(String sValue) {
        String sReturn = "";
        BASE64Decoder decoder = new BASE64Decoder();

        try {
            sReturn = new String(decoder.decodeBuffer(sValue));
        }
        catch (Exception e) {
            if(Debug.enabled) Debug.println("User decoding error: "+e.getMessage());
        }

        return sReturn;
    }
%>

<%
    String sUserID, sPassword;
    byte[] aPassword;
    User testUser = new User();

    String sSelect = "SELECT userid, password FROM Users";
  	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
    PreparedStatement ps = ad_conn.prepareStatement(sSelect);
    ResultSet rs = ps.executeQuery();

    while (rs.next()) {
        sUserID = rs.getString("userid");
        sPassword = rs.getString("password");
        aPassword = testUser.encrypt(sPassword);

        sSelect = "UPDATE Users SET encryptedpassword = ? WHERE userid = ?";
        PreparedStatement ps2 = ad_conn.prepareStatement(sSelect);
        ps2.setBytes(1,aPassword);
        ps2.setInt(2,Integer.parseInt(sUserID));
        ps2.executeUpdate();
        ps2.close();
        //out.println(sUserID+" = "+sPassword+" = "+sEncryptedPassword+"<br>");
    }
	rs.close();
    ps.close();
    ad_conn.close();
%>

Passwords are converted.