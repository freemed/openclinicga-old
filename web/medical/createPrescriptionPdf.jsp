<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%@page import="java.io.ByteArrayOutputStream,
                com.itextpdf.text.DocumentException,
                java.io.PrintWriter,be.mxs.common.util.pdf.general.PDFPatientLabelGenerator" %>
<%@ page import="be.mxs.common.util.pdf.general.PDFArchiveLabelGenerator" %>
<%@ page import="be.mxs.common.util.pdf.general.PDFPrescriptionGenerator" %>
<%@ page import="be.openclinic.medical.PaperPrescription" %>
<%
    ByteArrayOutputStream baosPDF = null;

    try {
        // Save the prescription first
        java.util.Date date = new java.util.Date();
        try{
            date=ScreenHelper.parseDate(checkString(request.getParameter("prescriptiondate")));
        }
        catch (Exception e){
        }
        PaperPrescription paperPrescription = new PaperPrescription(date,checkString(request.getParameter("prescription")),activePatient.personid,activeUser.userid);
        paperPrescription.store();
        // PDF generator
        PDFPrescriptionGenerator pdfPrescriptionGenerator = new PDFPrescriptionGenerator(activeUser, sProject);
        baosPDF = pdfPrescriptionGenerator.generatePDFDocumentBytes(request, activePatient, checkString(request.getParameter("prescription")),checkString(request.getParameter("prescriptiondate")));
        StringBuffer sbFilename = new StringBuffer();
        sbFilename.append("filename_").append(System.currentTimeMillis()).append(".pdf");

        StringBuffer sbContentDispValue = new StringBuffer();
        sbContentDispValue.append("inline; filename=").append(sbFilename);

        // prepare response
        response.setHeader("Cache-Control", "max-age=30");
        response.setContentType("application/pdf");
        response.setHeader("Content-disposition", sbContentDispValue.toString());
        response.setContentLength(baosPDF.size());

        // write PDF to servlet
        ServletOutputStream sos = response.getOutputStream();
        baosPDF.writeTo(sos);
        sos.flush();
    }
    catch
        (DocumentException
        dex
        )
    {
        response.setContentType("text/html");
        PrintWriter writer = response.getWriter();
        writer.println(this.getClass().getName() + " caught an exception: " + dex.getClass().getName() + "<br>");
        writer.println("<pre>");
        dex.printStackTrace(writer);
        writer.println("</pre>");
    }
    finally
    {
        if (baosPDF != null) {
            baosPDF.reset();
        }
    }
%>