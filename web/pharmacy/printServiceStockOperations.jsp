<%@ page import="be.openclinic.pharmacy.*,java.io.*,be.mxs.common.util.system.*,be.mxs.common.util.pdf.general.*,org.dom4j.*" %>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%
	String sBeginDate = checkString(request.getParameter("FindBeginDate"));
	String sEndDate = checkString(request.getParameter("FindEndDate"));
	String sServiceStockId=checkString(request.getParameter("ServiceStockUid"));
    sProject = checkString((String)session.getAttribute("activeProjectTitle")).toLowerCase();
	PDFPharmacyReportGenerator pdfGenerator = new PDFPharmacyReportGenerator(activeUser,sProject);
    ByteArrayOutputStream baosPDF = null;
    try {
        Hashtable parameters = new Hashtable();
        parameters.put("serviceStockUID",sServiceStockId);
        parameters.put("begin",sBeginDate);
        parameters.put("end",sEndDate);
    	baosPDF = pdfGenerator.generatePDFDocumentBytes(request,"serviceStockOperations",parameters);
        StringBuffer sbFilename = new StringBuffer();
        sbFilename.append("filename_").append(System.currentTimeMillis()).append(".pdf");

        StringBuffer sbContentDispValue = new StringBuffer();
        sbContentDispValue.append("inline; filename=")
                          .append(sbFilename);

        // prepare response
        response.setHeader("Cache-Control","max-age=30");
        response.setContentType("application/pdf");
        response.setHeader("Content-disposition",sbContentDispValue.toString());
        response.setContentLength(baosPDF.size());

        // write PDF to servlet
        ServletOutputStream sos = response.getOutputStream();
        baosPDF.writeTo(sos);
        sos.flush();
    }
	catch(Exception dex){
        response.setContentType("text/html");
        PrintWriter writer = response.getWriter();
        writer.println(this.getClass().getName()+ " caught an exception: "+ dex.getClass().getName()+ "<br>");
        writer.println("<pre>");
        dex.printStackTrace(writer);
        writer.println("</pre>");
    }
    finally{
        if(baosPDF != null) {
            baosPDF.reset();
        }
    }
%>