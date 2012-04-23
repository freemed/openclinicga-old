<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%@page import="java.io.ByteArrayOutputStream,
                com.lowagie.text.DocumentException,
                java.io.PrintWriter,be.mxs.common.util.pdf.general.*, be.openclinic.id.Barcode" %>
<%
    ByteArrayOutputStream baosPDF = null;
    Barcode barcode = new Barcode();
    barcode.setPersonid(Integer.parseInt(activePatient.personid));
    barcode.setUserid(Integer.parseInt(activeUser.userid));
    barcode.store();

    try {
        // PDF generator
        PDFOpeninsuranceCardGenerator pdfPatientCardGenerator = new PDFOpeninsuranceCardGenerator(activeUser, sProject);
        baosPDF = pdfPatientCardGenerator.generatePDFDocumentBytes(request, activePatient);
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