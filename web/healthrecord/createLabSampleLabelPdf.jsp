<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%@page import="java.io.ByteArrayOutputStream,
                com.itextpdf.text.DocumentException,
                java.io.PrintWriter
                ,java.util.*,
                be.openclinic.medical.LabRequest,be.openclinic.medical.LabSample" %>
<%@ page import="be.mxs.common.util.pdf.general.PDFLabSampleLabelGenerator" %>
<%
    ByteArrayOutputStream baosPDF = null;
    Vector samples = new Vector();
    Enumeration parameters = request.getParameterNames();
    while (parameters.hasMoreElements()) {
        String name = (String) parameters.nextElement();
        String fields[] = name.split("\\.");
        if (fields[0].equalsIgnoreCase("execute") && fields.length == 4) {
            Hashtable hashtable = new Hashtable();
            hashtable.put("serverid", fields[1]);
            hashtable.put("transactionid", fields[2]);
            hashtable.put("sample", fields[3]);
            samples.add(hashtable);
        }
    }
    if (samples.size() == 0 && request.getParameter("transactionid") != null) {
        Hashtable allsamples = LabRequest.getUnsampledRequest(Integer.parseInt(request.getParameter("serverid")), Integer.parseInt(request.getParameter("transactionid"))+"", sWebLanguage).findAllSamples(sWebLanguage);
        Enumeration enumeration = allsamples.elements();
        while (enumeration.hasMoreElements()) {
            LabSample labSample = (LabSample)enumeration.nextElement();
            Hashtable hashtable = new Hashtable();
            hashtable.put("serverid",request.getParameter("serverid") );
            hashtable.put("transactionid", request.getParameter("transactionid"));
            hashtable.put("sample", labSample.type);
            samples.add(hashtable);
        }
    }

    try {
        // PDF generator
        PDFLabSampleLabelGenerator pdfLabSampleLabelGenerator = new PDFLabSampleLabelGenerator(activeUser, sProject);
        baosPDF = pdfLabSampleLabelGenerator.generatePDFDocumentBytes(request, samples);
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