<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%@page import="java.io.ByteArrayOutputStream,
                com.lowagie.text.DocumentException,
                java.io.PrintWriter"%>
<%@ page import="be.openclinic.finance.*" %>
<%@ page import="be.mxs.common.util.pdf.general.*" %>

<%
    String sCreditUid    = checkString(request.getParameter("CreditUid")),
           sPrintLanguage = checkString(request.getParameter("PrintLanguage"));
    ByteArrayOutputStream baosPDF = null;

    try{
        // PDF generator
        WicketDebet credit = WicketDebet.get(sCreditUid);
        sProject = checkString((String)session.getAttribute("activeProjectTitle")).toLowerCase();
        PDFWicketDebetProofGenerator pdfGenerator = new PDFWicketDebetProofGenerator(activeUser,credit,sProject,sPrintLanguage);
        baosPDF = pdfGenerator.generatePDFDocumentBytes(request,sCreditUid);

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
    catch(DocumentException dex){
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