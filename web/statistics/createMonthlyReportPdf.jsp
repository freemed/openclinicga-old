<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%@page import="java.io.ByteArrayOutputStream,
                com.itextpdf.text.DocumentException,
                java.io.PrintWriter,be.mxs.common.util.pdf.general.PDFPatientCardGenerator, be.openclinic.id.Barcode" %>
<%@ page import="be.mxs.common.util.pdf.general.PDFMonthlyReportGenerator" %>
<%@ page import="org.hnrw.report.Report_RFE" %>
<%
    ByteArrayOutputStream baosPDF = null;
	java.util.Date start = new SimpleDateFormat("dd/MM/yyyy HH:mm").parse(checkString(request.getParameter("start"))+" 23:59");
	java.util.Date end = new SimpleDateFormat("dd/MM/yyyy HH:mm").parse(checkString(request.getParameter("end"))+" 23:59");
    Report_RFE report_rfe = new Report_RFE(start,end,"visit");
    for(int n=0;n<report_rfe.rfes.size();n++){
        Report_RFE.RFE rfe = (Report_RFE.RFE)report_rfe.rfes.elementAt(n);
    }
    try {
        // PDF generator
        PDFMonthlyReportGenerator pdfMonthlyReportGenerator = new PDFMonthlyReportGenerator(activeUser, sProject);
        baosPDF = pdfMonthlyReportGenerator.generatePDFDocumentBytes(request, start,end);
        StringBuffer sbFilename = new StringBuffer();
        sbFilename.append("filename_").append(System.currentTimeMillis()).append(".pdf");

        StringBuffer sbContentDispValue = new StringBuffer();
        sbContentDispValue.append("inline; filename=")
                .append(sbFilename);

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
    catch (DocumentException dex) {
        response.setContentType("text/html");
        PrintWriter writer = response.getWriter();
        writer.println(this.getClass().getName() + " caught an exception: " + dex.getClass().getName() + "<br>");
        writer.println("<pre>");
        dex.printStackTrace(writer);
        writer.println("</pre>");
    }
    finally {
        if (baosPDF != null) {
            baosPDF.reset();
        }
    }
%>