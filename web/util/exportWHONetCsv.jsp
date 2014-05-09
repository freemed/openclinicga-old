<%@page import="java.io.*,java.sql.*,java.text.*,java.util.*,be.mxs.common.util.db.*,be.mxs.common.util.io.WHONet.*,be.mxs.common.util.system.*,be.openclinic.medical.*" %><%@page errorPage="/includes/error.jsp"%>
<%
	String message = "";
	String sWebLanguage=request.getParameter("language");
	java.util.Date exportdate= new SimpleDateFormat("yyyyMMddHHmmss").parse(MedwanQuery.getInstance().getConfigString("lastWHONetExport","19000101000000"));
	try{
		exportdate = new SimpleDateFormat("dd/MM/yyyy HH:mm:ss").parse(request.getParameter("exportdate")+" "+request.getParameter("exporttime"));
		System.out.println("exportdate="+new SimpleDateFormat("yyyyMMddHHmmss").format(exportdate));
		StringBuffer exportstring = WHONetUtils.getWHONetFile(exportdate,true);
	    response.setContentType("application/octet-stream");
	    response.setHeader("Content-Disposition", "Attachment;Filename=\"OpenClinicWHONetExport" + new SimpleDateFormat("yyyyMMddHHmmss").format(new java.util.Date()) + ".csv\"");
	    ServletOutputStream os = response.getOutputStream();
	    System.out.println(exportstring.toString());
	    byte[] b = exportstring.toString().getBytes();
	    for (int n=0;n<b.length;n++) {
	        os.write(b[n]);
	    }
	    os.flush();
	    os.close();
	}
	catch(Exception e){
		e.printStackTrace();
	}
%>
