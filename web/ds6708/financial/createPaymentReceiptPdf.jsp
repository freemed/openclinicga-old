<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%@page import="java.io.ByteArrayOutputStream,
                com.itextpdf.text.DocumentException,
                java.io.PrintWriter,
                be.mxs.common.util.pdf.general.PDFPatientInvoiceGenerator,
                be.mxs.common.util.pdf.general.PDFInvoiceGenerator"%>
<%@ page import="be.openclinic.finance.Invoice" %>
<%@ page import="be.openclinic.finance.PatientInvoice" %>
<%@ page import="be.openclinic.finance.PatientCredit" %>
<%@ page import="be.mxs.common.util.pdf.general.PDFReceiptGenerator" %>

<%
    String sCreditUid    = checkString(request.getParameter("CreditUid")),
           sPrintLanguage = checkString(request.getParameter("PrintLanguage"));
    ByteArrayOutputStream baosPDF = null;

    try{
        // PDF generator
        PatientCredit credit = PatientCredit.get(sCreditUid);
        sProject = checkString((String)session.getAttribute("activeProjectTitle")).toLowerCase();
        PDFReceiptGenerator pdfGenerator = new PDFReceiptGenerator(activeUser,credit.getEncounter().getPatient(),sProject,sPrintLanguage);
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