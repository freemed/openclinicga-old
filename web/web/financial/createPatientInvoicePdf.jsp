<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%@page import="java.io.ByteArrayOutputStream,
                com.lowagie.text.DocumentException,
                java.io.PrintWriter,
                be.mxs.common.util.pdf.general.PDFPatientInvoiceGenerator,
                be.mxs.common.util.pdf.general.PDFInvoiceGenerator"%>
<%@ page import="be.openclinic.finance.Invoice" %>
<%@ page import="be.openclinic.finance.PatientInvoice" %>
<%
    String sInvoiceUid    = checkString(request.getParameter("InvoiceUid")),
           sPrintLanguage = checkString(request.getParameter("PrintLanguage")),
           sProforma      = checkString(request.getParameter("Proforma"));
    ByteArrayOutputStream baosPDF = null;

    try{
        // PDF generator
        PatientInvoice invoice = PatientInvoice.get(sInvoiceUid);
        sProject = checkString((String)session.getAttribute("activeProjectTitle")).toLowerCase();
        PDFInvoiceGenerator pdfGenerator = new PDFPatientInvoiceGenerator(activeUser,invoice.getPatient(),sProject,sPrintLanguage,sProforma);
        baosPDF = pdfGenerator.generatePDFDocumentBytes(request,sInvoiceUid);

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
            baosPDF=null;
        }
    }
%>