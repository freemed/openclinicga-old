<%@page import="java.io.ByteArrayOutputStream,
                com.itextpdf.text.DocumentException,
                java.io.PrintWriter,
                be.mxs.common.util.pdf.general.PDFArchiveDocumentBarcodeGenerator"%>
<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>

<%
    ByteArrayOutputStream baosPDF = null;

    try{    	
    	PDFArchiveDocumentBarcodeGenerator gen = new PDFArchiveDocumentBarcodeGenerator(activeUser,sProject);
        baosPDF = gen.generatePDFDocumentBytes(request,activePatient);
        
        StringBuffer sbFilename = new StringBuffer();
        sbFilename.append("filename_").append(System.currentTimeMillis()).append(".pdf");

        StringBuffer sbContentDispValue = new StringBuffer();
        sbContentDispValue.append("inline; filename=").append(sbFilename);

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
    catch(DocumentException dex){
        response.setContentType("text/html");
        
        PrintWriter writer = response.getWriter();
        writer.println(this.getClass().getName()+" caught an exception: "+dex.getClass().getName()+"<br>");
        writer.println("<pre>");
        dex.printStackTrace(writer);
        writer.println("</pre>");
    }
    finally{
        if(baosPDF!=null) baosPDF.reset();
    }
%>