<%@page import="java.io.ByteArrayOutputStream,java.io.PrintWriter,java.text.*"%><%@ page import="be.openclinic.sync.*" %>
<%
    try{
        // XML generator
        OpenclinicExporter exporter = new OpenclinicExporter();
        response.setContentType("application/octet-stream");
        response.setHeader("Content-Disposition", "Attachment;Filename=\"OpenClinicExport" + new SimpleDateFormat("yyyyMMddHHmmss").format(new java.util.Date()) + ".xml\"");
        ServletOutputStream os = response.getOutputStream();
        byte[] b = null;
        try{
        	b = exporter.run().getBytes();
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
    catch(Exception dex){
        response.setContentType("text/html");
        PrintWriter writer = response.getWriter();
        writer.println(this.getClass().getName()+ " caught an exception: "+ dex.getClass().getName()+ "<br>");
        writer.println("<pre>");
        dex.printStackTrace(writer);
        writer.println("</pre>");
    }
%>