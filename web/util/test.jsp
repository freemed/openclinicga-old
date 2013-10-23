<%@page import="be.mxs.common.util.export.*"%>
<%@ page import="java.util.*,org.dom4j.*,java.text.*,java.io.*" %>
<%
	ExportMessage message = new ExportMessage(60);
	message.createExportMessage();
    response.setContentType("application/octet-stream; charset=windows-1252");
    response.setHeader("Content-Disposition", "Attachment;Filename=\"export" + new SimpleDateFormat("yyyyMMddHHmmss").format(message.getStart()) + ".xml\"");
    ServletOutputStream os = response.getOutputStream();
    byte[] b = message.getDocument().asXML().replaceAll("&amp;","&").getBytes();
    for (int n=0;n<b.length;n++) {
        os.write(b[n]);
    }
    os.flush();
    os.close();
	
%>