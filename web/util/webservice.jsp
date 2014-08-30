<%@page import="java.io.*,be.mxs.common.util.system.Base64Coder,net.admin.*,org.apache.commons.io.IOUtils,be.mxs.common.util.system.SessionMessage,java.util.*,be.mxs.common.util.db.*,org.dom4j.*,java.io.ByteArrayOutputStream,java.io.PrintWriter,java.text.*"%><%@ page import="be.openclinic.sync.*" %>
<%
	try{
	InputStream input = request.getInputStream();
    String xml = IOUtils.toString(input);
	System.out.println("00: "+xml);

    if(xml!=null){
    	System.out.println("01");
		Document message = DocumentHelper.parseText(xml);
    	System.out.println("02");
		Element root = message.getRootElement();
    	System.out.println("03");
		//First check if this is a valid login
		String login =root.attributeValue("login");
    	System.out.println("04: "+root.attributeValue("password"));
		byte[] encryptedpassword = Base64Coder.decode(root.attributeValue("password"));
    	System.out.println("05");
		System.out.println("0: "+message.asXML());
		if(!User.validate(login, encryptedpassword)){
			System.out.println("0.1: "+message.asXML());
			message=DocumentHelper.createDocument();
			message.setRootElement(DocumentHelper.createElement("export"));
			message.getRootElement().addAttribute("error", "remote.login.error");
		}
		else if(!User.hasAccessRight(login, "exportslavedata","select")){
			System.out.println("0.2: "+message.asXML());
			message=DocumentHelper.createDocument();
			message.setRootElement(DocumentHelper.createElement("export"));
			message.getRootElement().addAttribute("error", "remote.login.nopermission");
		}
		else if(root.attributeValue("command").equalsIgnoreCase("getIds")){
			System.out.println("1: "+message.asXML());
			root.setAttributeValue("command", "setIds");
			OpenclinicSlaveExporter openclinicSlaveExporter = new OpenclinicSlaveExporter(new SessionMessage());
			message=openclinicSlaveExporter.getNewIds(message);
		}
		else if(root.attributeValue("command").equalsIgnoreCase("store")){
			System.out.println("2: "+message.asXML());
			OpenclinicSlaveExporter openclinicSlaveExporter = new OpenclinicSlaveExporter(new SessionMessage());
			message=openclinicSlaveExporter.store(message);
		}
        response.setContentType("application/octet-stream");
        response.setHeader("Content-Disposition", "Attachment;Filename=\"OpenClinicExport" + new SimpleDateFormat("yyyyMMddHHmmss").format(new java.util.Date()) + ".xml\"");
        ServletOutputStream os = response.getOutputStream();
		System.out.println("return: "+message.asXML());
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
	catch(Exception e){
		e.printStackTrace();
	}
%>