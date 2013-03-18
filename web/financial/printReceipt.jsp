<%@ page import="sun.misc.*,be.mxs.common.util.io.*,org.apache.commons.httpclient.*,org.apache.commons.httpclient.methods.*,be.mxs.common.util.db.*,be.mxs.common.util.system.*,be.openclinic.finance.*,net.admin.*,java.util.*,java.text.*,be.openclinic.adt.*" %>
<%@include file="/includes/SingletonContainer.jsp"%>

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
	reloadSingleton(session);
	JavaPOSPrinter printer = new JavaPOSPrinter();	
	printer.printReceipt(request.getParameter("project"), request.getParameter("language"),HTMLEntities.unhtmlentities(request.getParameter("content")),request.getParameter("id"));
%>