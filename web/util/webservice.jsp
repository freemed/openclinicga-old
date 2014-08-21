<%@page import="be.mxs.common.util.system.SessionMessage,java.util.*,be.mxs.common.util.db.*,org.dom4j.*,java.io.ByteArrayOutputStream,java.io.PrintWriter,java.text.*"%><%@ page import="be.openclinic.sync.*" %>
<%
	try{
	String xml = request.getParameter("xml");
	if(xml!=null){
		Document message = DocumentHelper.parseText(xml);
		Element root = message.getRootElement();
		if(root.attributeValue("command").equalsIgnoreCase("getIds")){
			root.setAttributeValue("command", "setIds");
			OpenclinicSlaveExporter openclinicSlaveExporter = new OpenclinicSlaveExporter(new SessionMessage());
			System.out.println("message="+message.asXML());
			message=openclinicSlaveExporter.getNewIds(message);
			System.out.println("newmessage="+message.asXML());
	        response.setContentType("application/octet-stream");
	        response.setHeader("Content-Disposition", "Attachment;Filename=\"OpenClinicExport" + new SimpleDateFormat("yyyyMMddHHmmss").format(new java.util.Date()) + ".xml\"");
	        ServletOutputStream os = response.getOutputStream();
	        byte[] b = null;
	        try{
	        	b = message.asXML().getBytes();
	        }
	        catch(Exception e){
	        	e.printStackTrace();
	        }
	        for (int n=0;n<b.length;n++) {
	            os.write(b[n]);
	        }
	        os.flush();
	        os.close();
		}
		else if(root.attributeValue("command").equalsIgnoreCase("store")){
			OpenclinicSlaveExporter openclinicSlaveExporter = new OpenclinicSlaveExporter(new SessionMessage());
			message=openclinicSlaveExporter.store(message);
	        response.setContentType("application/octet-stream");
	        response.setHeader("Content-Disposition", "Attachment;Filename=\"OpenClinicExport" + new SimpleDateFormat("yyyyMMddHHmmss").format(new java.util.Date()) + ".xml\"");
	        ServletOutputStream os = response.getOutputStream();
	        byte[] b = null;
	        try{
	        	b = message.asXML().getBytes();
	        }
	        catch(Exception e){
	        	e.printStackTrace();
	        }
	        for (int n=0;n<b.length;n++) {
	            os.write(b[n]);
	        }
	        os.flush();
	        os.close();
		}
	}
	}
	catch(Exception e){
		e.printStackTrace();
	}
%>